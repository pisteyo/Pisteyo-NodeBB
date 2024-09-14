'use strict';

const db = require('../database');
const user = require('../user');

const leaderboardController = module.exports;

leaderboardController.getLeaderboard = async function (req, res) {
    const type = req.query.type || 'active';
    const count = 10;

    let users;
    if (type === 'active') {
        users = await getMostActiveUsers(count);
    } else if (type === 'upvoted') {
        users = await getMostUpvotedUsers(count);
    } else {
        return res.status(400).json({ error: 'Invalid leaderboard type' });
    }

    res.json(users);
};

leaderboardController.getActivityVolume = async function (req, res) {
    const { start, end, interval } = req.query;
    const startDate = new Date(start);
    const endDate = new Date(end);
    const intervalMs = interval * 24 * 60 * 60 * 1000; // Convert days to milliseconds

    const results = await Promise.all([
        getVolumeForSet('topics:tid', startDate, endDate, intervalMs),
        getVolumeForSet('posts:pid', startDate, endDate, intervalMs),
        getVolumeForSet('comments:cid', startDate, endDate, intervalMs),
    ]);

    const activityVolume = results[0].map((topic, index) => ({
        timestamp: topic.timestamp,
        topics: topic.count,
        posts: results[1][index].count,
        comments: results[2][index].count,
        total: topic.count + results[1][index].count + results[2][index].count,
    }));

    res.json(activityVolume);
};

async function getMostActiveUsers(count) {
    const uids = await db.getSortedSetRevRange('users:postcount', 0, count - 1);
    return await getUsersData(uids);
}

async function getMostUpvotedUsers(count) {
    const uids = await db.getSortedSetRevRange('users:reputation', 0, count - 1);
    return await getUsersData(uids);
}

async function getUsersData(uids) {
    return await user.getUsersFields(uids, ['uid', 'username', 'userslug', 'picture', 'postcount', 'reputation']);
}

async function getVolumeForSet(set, startDate, endDate, intervalMs) {
    const counts = [];
    for (let timestamp = startDate.getTime(); timestamp <= endDate.getTime(); timestamp += intervalMs) {
        const count = await db.sortedSetCount(set, timestamp, timestamp + intervalMs - 1);
        counts.push({ timestamp, count });
    }
    return counts;
}