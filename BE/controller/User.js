const User = require("../models/user");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const { email, name, password } = req.body;
    const user = await User.findOne({ email: email });
    if (user) {
      return res.status(409).send({ message: "Email đã được sử dụng" });
    }
    const hashPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      email: email,
      name: name,
      password: hashPassword,
    });
    await newUser.save();
    res.status(200).send({ status: "success", message: "Đăng kí thành công" });
  } catch (err) {
    res
      .status(500)
      .send({ status: "error", message: err.message, stack: err.stack });
  }
};
exports.login = async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });
    if (!user) {
      return res.status(404).send({ message: "Email chưa được đăng kí" });
    }
    const IsPassword = await bcrypt.compare(req.body.password, user.password);
    if (!IsPassword) {
      return res.status(404).send({ message: "Mật khẩu không chính xác" });
    }

    const token = jwt.sign({ userId: user._id }, "Secret");
    const { password, ...others } = user._doc;
    res.status(200).send({
      status: "success",
      message: "Đăng nhập thành công",
      data: {
        others,
        token,
      },
    });
  } catch (err) {
    res
      .status(500)
      .send({ status: "error", message: err.message, stack: err.stack });
  }
};
exports.logout = (req, res) => {
  req.session.destroy();
  res.clearCookie("access_token").status(200).json("User has been logged out.");
};

exports.saveToken = async (req, res) => {
  try {
    const { token, email } = req.body;
    const user = await User.findOne({ email: email });
    if (!user) {
      return res
        .status(401)
        .json({ status: "error", message: "Unauthorized: User ID not found." });
    }

    // Xoá token khỏi user khác (nếu có)
    await User.updateMany(
      { deviceTokens: token },
      { $pull: { deviceTokens: token } },
    );

    // Push token vào user hiện tại (chỉ khi chưa tồn tại)
    await User.findByIdAndUpdate(
      user._id,
      { $addToSet: { deviceTokens: token } }, // $addToSet = không cho trùng
      { new: true },
    );

    res
      .status(200)
      .send({ status: "success", message: "Token saved successfully" });
  } catch (err) {
    res.status(500).send({ status: "error", message: err.message });
  }
};
exports.removeToken = async (req, res) => {
  try {
    const { token, email } = req.body;
    const user = await User.findOne({ email: email });
    if (!user) {
      return res
        .status(401)
        .json({ status: "error", message: "Unauthorized: User ID not found." });
    }

    await User.findByIdAndUpdate(user._id, {
      $pull: { deviceTokens: token },
    });

    res
      .status(200)
      .send({ status: "success", message: "Token removed successfully" });
  } catch (err) {
    res.status(500).send({ status: "error", message: err.message });
  }
};
