const express = require("express")
const app = express()
const { getValue, setValue } = require("./repo.js")
const cors = require("cors")
const fs = require("fs")
const path = require("path")
const port = 3000

app.use(cors())
app.use(express.json())

app.get("/", (req, res) => {
    res.send('Express server for automating HA microk8s rollout.')
})
// connection string
app.get("/connction-string", (req, res) => {
    const temp = getValue(["connection-string"])
    const arrVal = temp === undefined ? [] : temp
    const conString = arrVal.pop()

    setValue(["connection-string"], arrVal)
    res.send(conString)
})

app.put("/connection-string", (req, res) => {
    const temp = getValue(["connection-string"])
    const curr = temp === undefined ? [] : temp

    curr.add(req.body.constring)
    // uniqueIPs.add(req.body.ip)
    // if (uniqueIPs.size > 1)
    setValue(["connection-string"], curr)

    // setValue(["master", "ip"], req.body.ip)
    res.status(200).send()

})

app.listen(port, () => {
    console.log(`Express server listening on ${port}`)
})