const Device = require("../models/devices");
const { sendPushNotification } = require("../service/sendNotification");
const User = require("../models/user");

exports.AddDevice = async (req, res) => {
  try {
    const { device_name, url, email } = req.body;
    // console.log(req.body);
    // const user = await User.findOne({ email });
    // if (!user) {
    //   return res.status(404).send({ message: "Không tìm thấy người dùng" });
    // }
    const newDevice = new Device({
      device_name,
      url,
    });

    // user.deviceTokens.map((token) => {
    //   sendPushNotification(
    //     token,
    //     "Thêm mới thiết bị thành công",
    //     `Thiết bị ${device_name} đã được thêm thành công`,
    //   );
    // });
    await newDevice.save();
    res.status(200).send({ message: "Thêm mới thiết bị thành công" });
  } catch (err) {
    res.status(500).send({ message: err.message, err: err.stack });
  }
};
exports.getAll = async (req, res) => {
  try {
    const devices = await Device.find();
    if (!devices) {
      return res
        .status(404)
        .send({ message: "Chưa có thiết bị nào được kết nối" });
    }
    res.status(200).send({
      data: devices,
    });
  } catch (err) {
    res.status(500).send({ message: err.message, err: err.stack });
  }
};
exports.delete = async (req, res) => {
  try {
    const device = await Device.findByIdAndDelete(req.params.id);
    if (!device) {
      return res.status(404).send({ message: "Không tìm thấy thiết bị" });
    }
    res.status(200).send({ message: "Xóa thành công" });
  } catch (err) {
    res.status(500).send({ message: err.message, err: err.stack });
  }
};

exports.updateROI = async (req, res) => {
  try {
    const { id } = req.params;
    const { x, y, width, height, is_detection_enabled } = req.body;
    
    const updateData = {};
    if (x !== undefined) updateData['detection_roi.x'] = x;
    if (y !== undefined) updateData['detection_roi.y'] = y;
    if (width !== undefined) updateData['detection_roi.width'] = width;
    if (height !== undefined) updateData['detection_roi.height'] = height;
    if (is_detection_enabled !== undefined) updateData['is_detection_enabled'] = is_detection_enabled;

    const device = await Device.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true }
    );

    if (!device) {
      return res.status(404).send({ message: "Không tìm thấy thiết bị" });
    }

    res.status(200).send({ message: "Cập nhật vùng nhận diện thành công", data: device });
  } catch (err) {
    res.status(500).send({ message: err.message });
  }
};
