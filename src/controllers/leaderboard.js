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