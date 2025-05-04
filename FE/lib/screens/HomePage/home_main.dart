import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/screens/HomePage/home_wrapper.dart';
import 'package:camera_app/services/device_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<Homepage> {
  final TextEditingController _nameDeviceController =
      TextEditingController();
  final TextEditingController _urlController =
      TextEditingController();
  final DeviceService _deviceService = DeviceService();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> buttonData = [
    {'icon': Icons.home, 'text': 'Home', 'index': 1},
    {
      'icon': Icons.baby_changing_station_rounded,
      'text': 'Baby',
      'index': 2,
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'text': 'Office',
      'index': 3,
    },
    {'icon': Icons.school, 'text': 'School', 'index': 4},
  ];

  final List<dynamic> listCamera = [];

  void getDevice() async {
    var result = await _deviceService.getDevice();

    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final resultData = result['success'];
      setState(() {
        listCamera.clear();
        listCamera.addAll(resultData);
      });
    }
  }

  late int _selectedButton;

  @override
  void initState() {
    super.initState();
    _selectedButton = buttonData[0]['index'];
    getDevice();
  }

  void addDevice() async {
    String device_name = _nameDeviceController.text.trim();
    String url = _urlController.text.trim();
    var result = await _deviceService.create(
      device_name,
      url,
    );

    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      getDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success']),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void deleteDevice(id) async {
    var result = await _deviceService.delete(id);

    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      getDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success']),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Thêm thiết bị mới",
                              ),
                              content: Form(
                                key: _formKey,
                                child: SizedBox(
                                  height: 180,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller:
                                            _nameDeviceController,
                                        decoration: InputDecoration(
                                          labelText:
                                              "Tên thiết bị ",
                                          labelStyle:
                                              TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                              ),
                                          border:
                                              OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value ==
                                                  null ||
                                              value
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Nhập tên thiết bị';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 18),
                                      TextFormField(
                                        controller:
                                            _urlController,
                                        decoration: InputDecoration(
                                          labelText:
                                              "Đường dẫn url",
                                          labelStyle:
                                              TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                              ),
                                          border:
                                              OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value ==
                                                  null ||
                                              value
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Nhập đường dẫn url';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },
                                  child: Text("Hủy"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey
                                        .currentState!
                                        .validate()) {
                                      addDevice();
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    }
                                  },
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.blue,
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                  child: Text("Thêm"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: CircleBorder(),
                        foregroundColor: Colors.blue,
                        backgroundColor:
                            const Color.fromARGB(
                              255,
                              228,
                              220,
                              220,
                            ),
                      ),
                      child: Icon(Icons.add, size: 30),
                    ),
                    Stack(
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (
                                BuildContext context,
                              ) {
                                return AlertDialog(
                                  content: Text(
                                    "Tính năng đang phát triển",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: TextButton.styleFrom(
                            shape: CircleBorder(),
                            foregroundColor: Colors.blue,
                            backgroundColor:
                                const Color.fromARGB(
                                  255,
                                  228,
                                  220,
                                  220,
                                ),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            size: 30,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Hi,  ${user?['email'] ?? 'Chưa có thông tin'}',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Be sure of your safety',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 32),
                Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            buttonData.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                      right: 16,
                                    ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedButton =
                                          item['index'];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _selectedButton ==
                                                item['index']
                                            ? Colors.blue
                                            : Colors
                                                .blue[50],
                                    foregroundColor:
                                        _selectedButton ==
                                                item['index']
                                            ? Colors.white
                                            : Colors.blue,
                                    fixedSize: Size(
                                      120,
                                      120,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                      side: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item['icon'],
                                        size: 30,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        item['text'],
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    SizedBox(height: 16),
                    Column(
                      children:
                          listCamera.map((item) {
                            var camera = item['url'] ?? '';
                            var cameraId =
                                item['_id'] ?? '';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                          16,
                                        ),
                                    child: Mjpeg(
                                      stream: camera,
                                      isLive: false,
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width:
                                          double.infinity,
                                      error: (
                                        context,
                                        error,
                                        stack,
                                      ) {
                                        return Container(
                                          color:
                                              Colors
                                                  .black12,
                                          height: 200,
                                          width:
                                              double
                                                  .infinity,
                                          alignment:
                                              Alignment
                                                  .center,
                                          child: Text(
                                            'Không thể kết nối tới thiết bị',
                                            style: TextStyle(
                                              color:
                                                  Colors
                                                      .red,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons
                                          .play_circle_fill,
                                      color: Colors.white
                                          .withOpacity(0.7),
                                      size: 64,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        HomeRoutes.detail,
                                        arguments: camera,
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: PopupMenuButton<
                                      String
                                    >(
                                      onSelected: (value) {
                                        if (value ==
                                            'delete') {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              BuildContext
                                              context,
                                            ) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Xác nhận xóa',
                                                ),
                                                content: Text(
                                                  'Bạn có chắc muốn xóa thiết bị này không?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: Text(
                                                      'Hủy',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // đóng modal trước
                                                      deleteDevice(
                                                        cameraId,
                                                      ); // sau đó xóa
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: Text(
                                                      'Xóa',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons
                                            .more_vert_sharp,
                                        color: Colors.white,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                              10,
                                            ),
                                      ),
                                      itemBuilder:
                                          (
                                            BuildContext
                                            context,
                                          ) => [
                                            PopupMenuItem<
                                              String
                                            >(
                                              value:
                                                  'delete',
                                              child: Text(
                                                'Xóa',
                                              ),
                                            ),
                                          ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
