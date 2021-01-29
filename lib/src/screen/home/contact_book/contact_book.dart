import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/models/contact_book_m.dart';
import 'package:wallet_apps/src/models/createAccountM.dart';
import 'package:wallet_apps/src/screen/home/contact_book/contact_book_body.dart';

class ContactBook extends StatefulWidget {

  // final CreateAccModel accModel;
  
  // final List contactList;

  // ContactBook(this.accModel, this.contactList);

  static const String route = '/contactList';

  @override
  _ContactBookState createState() => _ContactBookState();
}

class _ContactBookState extends State<ContactBook> {

  ContactBookModel _contactBookModel = ContactBookModel();

  void getContact() async {
    _contactBookModel.contactBookList.clear();
    var value = await StorageServices.fetchData('contactList');

    print(value);
    if(value == null) {
      _contactBookModel.contactBookList = null;
      print("My contact");
    }
    else {
      print("Ke contact");
      for(var i in value){
        _contactBookModel.contactBookList.add(
          ContactBookModel.initList(
            contactNum: i['phone'], 
            username: i['username'], 
            address: i['address'], 
            memo: i['memo'],
          ),
        );

      } 
    }
    print(_contactBookModel.contactBookList);
    setState(() {});
  }

  @override
  initState(){
    getContact();
    // print(widget.sdkModel.keyring.contacts)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyScaffold(
        height: MediaQuery.of(context).size.height,
        child: ContactBookBody(
          model: _contactBookModel,
          getContact: getContact
        )
      )
    );
  }
}