const User = require('../models/user')
const bcrypt = require("bcrypt")
const jwt = require('jsonwebtoken')


exports.register = async (req, res) => {
    try {
        const { email, name, password } = req.body;
        const user = await User.findOne({ email: email })
        if (user) {
            return res.status(409).send({ message: "Email đã được sử dụng" })
        }
        const hashPassword = await bcrypt.hash(password, 10);

        const newUser = new User({
            email: email,
            name: name,
            password: hashPassword,
        });
        await newUser.save();
        res.status(200).send({ message: "Đăng kí thành công" });
    } catch (err) {
        res.status(500).send({ message: err.message, stack: err.stack })
    }
}
exports.login = async (req, res) => {
    try {
        const user = await User.findOne({ email: req.body.email })
        if (!user) {
            return res.status(404).send({ message: "Email chưa được đăng kí" })
        }
        const IsPassword = await bcrypt.compare(req.body.password, user.password)
        if (!IsPassword) {
            return res.status(404).send({ message: "Mật khẩu không chính xác" })
        }

        const token = jwt.sign({ userId: user._id }, "Secret")
        const { password, ...others } = user._doc
        res.status(200).send({
            message: "Đăng nhập thành công",
            data: {
                others,
                token
            }
        })
    } catch (err) {
        res.status(500).send({ message: err.message, stack: err.stack })
    }
}
exports.logout = (req, res) => {
    req.session.destroy()
    res.clearCookie("access_token").status(200).json("User has been logged out.")
}