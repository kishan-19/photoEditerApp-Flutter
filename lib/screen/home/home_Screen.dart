import 'package:photoediter/export.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with WidgetsBindingObserver{
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadDataToHive();
    });
    WidgetsBinding.instance.addObserver(this);
    // context.read<HomeProvider>().loadDataToHive();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      context.read<HomeProvider>().saveToHive();
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HomeProvider>().offSelectionMode(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Photo Editor'),

          actions: [
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return Provider.isSelect.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    context.read<HomeProvider>().shareImage();
                  },
                  child: Icon(Icons.share_outlined),
                )
                    : SizedBox.shrink();
              },
            ),
            SizedBox(width: 10,),
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return Provider.isSelect.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          context.read<HomeProvider>().delectImage();
                          context.read<HomeProvider>().offSelectionMode();
                        },
                        child: Icon(Icons.delete),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
          actionsPadding: EdgeInsets.all(16),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Consumer<HomeProvider>(
            builder: (_, Provider, __) {
              if (Provider.photos.isEmpty) {
                return Center(
                  child: Text(
                    "Image not found",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: Provider.photos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:MediaQuery.of(context).orientation == Orientation.portrait ?  4 : 6,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                      childAspectRatio:MediaQuery.of(context).orientation == Orientation.portrait ? 0.62 :0.88
                  ),
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onLongPress: () {
                        context.read<HomeProvider>().addSelectValue(index);
                      },
                      onTap: () => {
                        Provider.selectionMode
                            ? context.read<HomeProvider>().addSelectValue(
                                index,
                              )
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoOpen(photoIndex: index),
                                ),
                              ),
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Provider.isSelect.map((element)=>element['image']).contains(Provider.photos[index]['image'])
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90,
                                child: ClipRRect(
                                  borderRadius:BorderRadiusGeometry.circular(6),
                                  child: Image.file(
                                    File(Provider.photos[index]['image']),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 118,
                                  ),
                                ),
                              ),
                              Text(
                                Provider.photos[index]['pixels'],
                                style: TextStyle(color: Colors.black54,letterSpacing: 0,fontWeight: FontWeight.bold,fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),

        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          childrenAnimation: ExpandableFabAnimation.none,
          distance: 60,

          overlayStyle: ExpandableFabOverlayStyle(
            color: Colors.white.withOpacity(0.9),
          ),

          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  context.read<HomeProvider>().pickImage(
                    ImageSource.camera,
                    context,
                  );
                },
                child: Row(
                  spacing: 8,
                  children: [Text('Camera'), Icon(Icons.camera_alt_outlined),],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<HomeProvider>().pickImage(
                  ImageSource.gallery,
                  context,
                );
                // Navigator.pop(context);
              },
              child: Row(
                spacing: 8,
                children: [
                  Text('Gallery '),
                  Icon(Icons.photo_library_outlined),
                ],
              ),
            ),
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return DropdownButton<String>(
                  value: Provider.dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  style: const TextStyle(color: Colors.black),
                  elevation: 16,
                  underline: Container(height: 2, color: Colors.black),
                  onChanged: (String? value) {
                    context.read<HomeProvider>().changeValueOfDropdown(value!);
                  },
                  items: Provider.list.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
