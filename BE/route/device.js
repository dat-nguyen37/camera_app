const route = require('express').Router()
const deviceController = require('../controller/Device')


route.post('/add_device', deviceController.AddDevice)
route.get('/getDevice', deviceController.getAll)
route.delete('/delete/:id', deviceController.delete)
route.put('/update_roi/:id', deviceController.updateROI)


module.exports = route
