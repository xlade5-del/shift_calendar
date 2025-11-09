const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onDocumentCreated, onDocumentUpdated, onDocumentDeleted} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const ICAL = require('ical.js');
const fetch = require('node-fetch');

admin.initializeApp();

/**
 * Check if current time is within user's quiet hours
 * @param {object} notificationSettings - User's notification settings
 * @return {boolean} True if currently in quiet hours
 */
function isQuietHours(notificationSettings) {
  if (!notificationSettings || !notificationSettings.quietHoursEnabled) {
    return false;
  }

  const startTimeStr = notificationSettings.quietHoursStart;
  const endTimeStr = notificationSettings.quietHoursEnd;

  if (!startTimeStr || !endTimeStr) {
    return false;
  }

  // Parse quiet hours times
  const [startHour, startMinute] = startTimeStr.split(':').map(Number);
  const [endHour, endMinute] = endTimeStr.split(':').map(Number);

  const now = new Date();
  const currentMinutes = now.getHours() * 60 + now.getMinutes();
  const startMinutes = startHour * 60 + startMinute;
  const endMinutes = endHour * 60 + endMinute;

  // Handle cases where quiet hours span midnight (e.g., 22:00 - 07:00)
  if (startMinutes > endMinutes) {
    // Quiet hours span midnight
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  } else {
    // Quiet hours within same day
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }
}

/**
 * Scheduled function to poll iCal feeds every 15 minutes
 * Fetches external calendar feeds and imports new/updated events
 */
exports.pollIcalFeeds = onSchedule({
  schedule: 'every 15 minutes',
  timeZone: 'America/New_York',
  memory: '256MiB',
}, async (event) => {
  const db = admin.firestore();

  try {
    // Get all users with active iCal feeds
    const usersSnapshot = await db.collection('users')
      .where('icalFeeds', '!=', null)
      .get();

    if (usersSnapshot.empty) {
      console.log('No users with iCal feeds found');
      return;
    }

    const importPromises = [];

    usersSnapshot.forEach((userDoc) => {
      const user = userDoc.data();
      const userId = userDoc.id;

      if (!user.icalFeeds || user.icalFeeds.length === 0) {
        return;
      }

      // Process each iCal feed for the user
      user.icalFeeds.forEach((feed) => {
        importPromises.push(importIcalFeed(userId, feed, db));
      });
    });

    const results = await Promise.allSettled(importPromises);

    const successful = results.filter((r) => r.status === 'fulfilled').length;
    const failed = results.filter((r) => r.status === 'rejected').length;

    console.log(`iCal import completed: ${successful} successful, ${failed} failed`);
    return {successful, failed};
  } catch (error) {
    console.error('Error in pollIcalFeeds:', error);
    throw error;
  }
});

/**
 * Import events from a single iCal feed
 * @param {string} userId - User ID
 * @param {object} feed - Feed object with url and metadata
 * @param {object} db - Firestore database instance
 */
async function importIcalFeed(userId, feed, db) {
  try {
    console.log(`Importing iCal feed for user ${userId}: ${feed.url}`);

    // Fetch iCal file via HTTPS
    const response = await fetch(feed.url, {
      headers: {
        'User-Agent': 'ShiftCalendar/1.0',
      },
      timeout: 10000, // 10 second timeout
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const icalData = await response.text();

    // Parse iCal data
    const jcalData = ICAL.parse(icalData);
    const comp = new ICAL.Component(jcalData);
    const vevents = comp.getAllSubcomponents('vevent');

    console.log(`Found ${vevents.length} events in iCal feed`);

    const batch = db.batch();
    let newEvents = 0;
    let updatedEvents = 0;

    for (const vevent of vevents) {
      const event = new ICAL.Event(vevent);

      // Extract event data
      const icalUid = event.uid;
      const title = event.summary || 'Untitled Event';
      const startTime = event.startDate.toJSDate();
      const endTime = event.endDate.toJSDate();
      const notes = event.description || '';
      const lastModified = event.component.getFirstPropertyValue('last-modified');

      // Check if event already exists
      const existingEventQuery = await db.collection('events')
        .where('userId', '==', userId)
        .where('icalUid', '==', icalUid)
        .where('source', '==', 'ical')
        .limit(1)
        .get();

      const now = admin.firestore.Timestamp.now();

      if (existingEventQuery.empty) {
        // Create new event
        const newEventRef = db.collection('events').doc();
        batch.set(newEventRef, {
          eventId: newEventRef.id,
          userId: userId,
          title: title,
          startTime: admin.firestore.Timestamp.fromDate(startTime),
          endTime: admin.firestore.Timestamp.fromDate(endTime),
          notes: notes,
          color: '#4285F4', // Default blue color
          source: 'ical',
          icalUid: icalUid,
          version: 1,
          createdAt: now,
          updatedAt: now,
        });
        newEvents++;
      } else {
        // Check if event was modified
        const existingEvent = existingEventQuery.docs[0];
        const existingData = existingEvent.data();

        // Compare last modified timestamps
        const shouldUpdate = lastModified &&
          new Date(lastModified.toJSDate()) > new Date(existingData.updatedAt.toDate());

        if (shouldUpdate) {
          batch.update(existingEvent.ref, {
            title: title,
            startTime: admin.firestore.Timestamp.fromDate(startTime),
            endTime: admin.firestore.Timestamp.fromDate(endTime),
            notes: notes,
            version: admin.firestore.FieldValue.increment(1),
            updatedAt: now,
          });
          updatedEvents++;
        }
      }
    }

    await batch.commit();

    // Update feed's lastSync timestamp
    await db.collection('users').doc(userId).update({
      'icalFeeds': admin.firestore.FieldValue.arrayRemove(feed),
    });

    await db.collection('users').doc(userId).update({
      'icalFeeds': admin.firestore.FieldValue.arrayUnion({
        ...feed,
        lastSync: now,
      }),
    });

    console.log(`iCal import completed for user ${userId}: ${newEvents} new, ${updatedEvents} updated`);
    return {userId, newEvents, updatedEvents};
  } catch (error) {
    console.error(`Error importing iCal feed for user ${userId}:`, error);
    throw error;
  }
}

/**
 * Triggered when a new event is created
 * Sends notification to partner about the new event
 */
exports.onEventCreated = onDocumentCreated({
  document: 'events/{eventId}',
  memory: '256MiB',
}, async (event) => {
  const eventData = event.data.data();
  const eventId = event.params.eventId;

  try {
    // Get the user who created the event
    const userId = eventData.userId;
    const userDoc = await admin.firestore().collection('users').doc(userId).get();

    if (!userDoc.exists) {
      console.log('User not found');
      return;
    }

    const user = userDoc.data();
    const partnerId = user.partnerId;

    if (!partnerId) {
      console.log('User has no partner');
      return;
    }

    // Get partner's FCM token
    const partnerDoc = await admin.firestore().collection('users').doc(partnerId).get();

    if (!partnerDoc.exists) {
      console.log('Partner not found');
      return;
    }

    const partner = partnerDoc.data();

    // Check notification settings
    if (!partner.notificationSettings?.partnerChanges) {
      console.log('Partner has disabled partner change notifications');
      return;
    }

    // Check quiet hours
    if (isQuietHours(partner.notificationSettings)) {
      console.log('Partner is in quiet hours, suppressing notification');
      return;
    }

    const fcmToken = partner.fcmToken;

    if (!fcmToken) {
      console.log('Partner has no FCM token');
      return;
    }

    // Format event time
    const startTime = eventData.startTime.toDate();
    const endTime = eventData.endTime.toDate();
    const dateStr = startTime.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
    const timeStr = `${startTime.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    })} - ${endTime.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    })}`;

    // Send notification
    const message = {
      token: fcmToken,
      notification: {
        title: `${user.name} added a shift`,
        body: `${eventData.title} on ${dateStr} (${timeStr})`,
      },
      data: {
        type: 'event_created',
        eventId: eventId,
        userId: userId,
      },
    };

    await admin.messaging().send(message);
    console.log(`Notification sent to partner ${partnerId} about new event ${eventId}`);
  } catch (error) {
    console.error('Error in onEventCreated:', error);
  }
});

/**
 * Triggered when an event is updated
 * Sends notification to partner about the change
 */
exports.onEventUpdated = onDocumentUpdated({
  document: 'events/{eventId}',
  memory: '256MiB',
}, async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  const eventId = event.params.eventId;

  try {
    // Skip if it's just a version increment without real changes
    const hasRealChanges =
      beforeData.title !== afterData.title ||
      beforeData.startTime.toMillis() !== afterData.startTime.toMillis() ||
      beforeData.endTime.toMillis() !== afterData.endTime.toMillis();

    if (!hasRealChanges) {
      return;
    }

    // Get the user who owns the event
    const userId = afterData.userId;
    const userDoc = await admin.firestore().collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return;
    }

    const user = userDoc.data();
    const partnerId = user.partnerId;

    if (!partnerId) {
      return;
    }

    // Get partner's FCM token
    const partnerDoc = await admin.firestore().collection('users').doc(partnerId).get();

    if (!partnerDoc.exists) {
      return;
    }

    const partner = partnerDoc.data();

    // Check notification settings
    if (!partner.notificationSettings?.partnerChanges) {
      return;
    }

    // Check quiet hours
    if (isQuietHours(partner.notificationSettings)) {
      console.log('Partner is in quiet hours, suppressing notification');
      return;
    }

    const fcmToken = partner.fcmToken;

    if (!fcmToken) {
      return;
    }

    // Send notification
    const message = {
      token: fcmToken,
      notification: {
        title: `${user.name} updated a shift`,
        body: `${afterData.title} was modified`,
      },
      data: {
        type: 'event_updated',
        eventId: eventId,
        userId: userId,
      },
    };

    await admin.messaging().send(message);
    console.log(`Notification sent to partner ${partnerId} about updated event ${eventId}`);
  } catch (error) {
    console.error('Error in onEventUpdated:', error);
  }
});

/**
 * Triggered when an event is deleted
 * Sends notification to partner about the deletion
 */
exports.onEventDeleted = onDocumentDeleted({
  document: 'events/{eventId}',
  memory: '256MiB',
}, async (event) => {
  const eventData = event.data.data();
  const eventId = event.params.eventId;

  try {
    // Get the user who owned the event
    const userId = eventData.userId;
    const userDoc = await admin.firestore().collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return;
    }

    const user = userDoc.data();
    const partnerId = user.partnerId;

    if (!partnerId) {
      return;
    }

    // Get partner's FCM token
    const partnerDoc = await admin.firestore().collection('users').doc(partnerId).get();

    if (!partnerDoc.exists) {
      return;
    }

    const partner = partnerDoc.data();

    // Check notification settings
    if (!partner.notificationSettings?.partnerChanges) {
      return;
    }

    // Check quiet hours
    if (isQuietHours(partner.notificationSettings)) {
      console.log('Partner is in quiet hours, suppressing notification');
      return;
    }

    const fcmToken = partner.fcmToken;

    if (!fcmToken) {
      return;
    }

    // Send notification
    const message = {
      token: fcmToken,
      notification: {
        title: `${user.name} deleted a shift`,
        body: `${eventData.title} was removed`,
      },
      data: {
        type: 'event_deleted',
        eventId: eventId,
        userId: userId,
      },
    };

    await admin.messaging().send(message);
    console.log(`Notification sent to partner ${partnerId} about deleted event ${eventId}`);
  } catch (error) {
    console.error('Error in onEventDeleted:', error);
  }
});
