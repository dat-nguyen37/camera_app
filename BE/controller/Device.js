const Device = require('../models/devices')

exports.AddDevice = async (req, res) => {
    try {
        const { device_name, url } = req.body
        const newDevice = new Device({
            device_name,
            url
        })
        await newDevice.save()
        res.status(200).send({ message: "Thêm mới thiết bị thành công" })
    } catch (err) {
        res.status(500).send({ message: err.message, err: err.stack })
    }
}
exports.getAll = async (req, res) => {
    try {
        const devices = await Device.find()
        if (!devices) {
            return res.status(404).send({ message: "Chưa có thiết bị nào được kết nối" })
        }
        res.status(200).send({
            data: devices
        })
    } catch (err) {
        res.status(500).send({ message: err.message, err: err.stack })
    }
}
exports.delete = async (req, res) => {
    try {
        const device = await Device.findByIdAndDelete(req.params.id);
        if (!device) {
            return res.status(404).send({ message: "Không tìm thấy thiết bị" });
        }
        res.status(200).send({ message: "Xóa thành công" })
    } catch (err) {
        res.status(500).send({ message: err.message, err: err.stack })
    }
}