const route = require("express").Router();
const userController = require("../controller/User");

route.post("/register", userController.register);
route.post("/login", userController.login);
route.post("/save-token", userController.saveToken);
route.post("/remove-token", userController.removeToken);

module.exports = route;
