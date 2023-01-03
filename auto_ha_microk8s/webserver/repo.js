const fs = require("fs")
const path = require("path")
const dbPath = "db/db.json"

function getValue(keys = []) {
    let db = getDB();
    for (key of keys) {
        db = db[key]
        if (db === undefined) return undefined
    }
    return db.val;
}

function setValue(keys = [], value = "") {
    const db = getDB();
    let curr = db;
    for (let i = 0; i < keys.length - 1; i++) {
        if (curr[keys[i]] === undefined)
            curr[keys[i]] = {}
        curr = curr[keys[i]]
    }
    curr[keys[keys.length - 1]] = { ...curr[keys[keys.length - 1]], "val": value }
    fs.writeFileSync(dbPath, JSON.stringify(db))

}

function getDB() {
    if (fs.existsSync(dbPath) === false)
        createDB();

    return JSON.parse(fs.readFileSync(dbPath))
}


function createDB() {
    if (fs.existsSync(path.dirname(dbPath)) === false)
        fs.mkdirSync(path.dirname(dbPath))
    const file = fs.openSync(dbPath, 'w')
    fs.writeFileSync(file, "{}")
}

module.exports = { getValue, setValue }