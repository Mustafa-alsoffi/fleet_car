import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import '../../models/car_model.dart';
import '../../services/car_service.dart';

class AddEditCarPage extends StatefulWidget {
  final Car? car;

  AddEditCarPage({this.car});

  @override
  _AddEditCarPageState createState() => _AddEditCarPageState();
}

class _AddEditCarPageState extends State<AddEditCarPage> {
  final _formKey = GlobalKey<FormState>();
  final carService = CarService();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _availabilityStatusController;
  late TextEditingController _conditionStatusController;
  // Add other controllers as needed
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedFileURL;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // add a method to remove the image
  void _removeImage() {
    setState(() {
      _image = null;
      _uploadedFileURL = null;
    });
  }

  Future<void> _uploadFile() async {
    if (_image == null) return;

    final fileName = Path.basename(_image!.path);
    final firebaseStorageRef =
        FirebaseStorage.instance.ref().child('/$fileName');

    final uploadTask = firebaseStorageRef.putFile(_image!);

    final taskSnapshot = await uploadTask.whenComplete(() => null);
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    setState(() {
      _uploadedFileURL = downloadURL;
    });

    print("File uploaded. Download URL: $_uploadedFileURL");
  }

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.car?.make ?? '');
    _modelController = TextEditingController(text: widget.car?.model ?? '');
    _availabilityStatusController = TextEditingController(
        text: widget.car?.availabilityStatus ?? 'available');
    _conditionStatusController =
        TextEditingController(text: widget.car?.conditionStatus ?? 'green');
    // Initialize other controllers with widget.car values if editing
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _availabilityStatusController.dispose();
    _conditionStatusController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Add Car' : 'Edit Car'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // add image field to upload to firebase storage and get url only
                // add image network to retrive the uplodaed image, otherwise show placeholder
                if (_uploadedFileURL != null)
                  Image.network(_uploadedFileURL!)
                else if (_image != null)
                  Image.file(_image!)
                else
                  // get the image from assets
                  Image.asset('assets/images/placeholder.jpg'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _image == null ? _pickImage : _removeImage,
                  child: _image == null
                      ? Text('Pick image')
                      : Text('Remove image',
                          style: TextStyle(color: Colors.red)),
                ),
                TextFormField(
                  controller: _makeController,
                  decoration: InputDecoration(labelText: 'Make'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car make';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car model';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _availabilityStatusController.text,
                  items: <String>['available', 'unavailable']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _availabilityStatusController.text = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Availability Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the availability status';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _conditionStatusController.text,
                  items: <String>['green', 'yellow', 'red']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: value == 'green'
                                ? Colors.green
                                : value == 'yellow'
                                    ? Colors.yellow
                                    : Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(value == 'green'
                              ? 'Good to go'
                              : value == 'yellow'
                                  ? 'Needs washing'
                                  : 'Broken'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _conditionStatusController.text = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Availability Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the availability status';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Handle save
                        final car = Car(
                          id: widget.car?.id ?? '',
                          availabilityStatus:
                              'available', // Replace with actual value
                          carId: '123', // Replace with actual value
                          conditionStatus: 'green', // Replace with actual value
                          customerIds: [], // Replace with actual value
                          licensePlate: 'ABC123', // Replace with actual value
                          make: _makeController.text,
                          mileage: 100, // Replace with actual value
                          model: _modelController.text,
                          picture:
                              'https://firebasestorage.googleapis.com/v0/b/cmts-3faa2.appspot.com/o/vehicle-placeholder.png?alt=media&token=6f8c0e6b-add2-4b6a-8590-beb943d161a0', // Replace with actual value
                          year: 2021, // Replace with actual value
                          // Add createdOn and updatedOn fields
                          createdOn: DateTime.now().toString(),
                          updatedOn: DateTime.now().toString(),
                        );

                        if (widget.car == null) {
                          // Add new car
                          // upload image to firebase storage
                          await _uploadFile();
                          await carService.createCar(
                            // generate randome id
                            carId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            availabilityStatus:
                                _availabilityStatusController.text,
                            conditionStatus: _conditionStatusController.text,
                            customerIds: car.customerIds,
                            licensePlate: car.licensePlate,
                            make: _makeController.text,
                            mileage: car.mileage,
                            model: _modelController.text,
                            picture: _uploadedFileURL ?? car.picture,
                            year: car.year,
                            createdOn: DateTime.now().toString(),
                            updatedOn: DateTime.now().toString(),
                          );
                        } else {
                          await carService.updateCar(
                              carId: widget.car!.id,
                              availabilityStatus:
                                  _availabilityStatusController.text,
                              conditionStatus: _conditionStatusController.text,
                              customerIds: car.customerIds,
                              licensePlate: car.licensePlate,
                              make: _makeController.text,
                              mileage: car.mileage,
                              model: _modelController.text,
                              picture: _uploadedFileURL ?? car.picture,
                              year: car.year,
                              updatedOn: DateTime.now().toString());
                        }

                        Navigator.pop(context);
                      }
                    },
                    child: Text(widget.car == null ? 'Add' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
