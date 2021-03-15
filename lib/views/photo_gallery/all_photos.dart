import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';

typedef BannerTapCallback = void Function(Photo photo);

class AllPhotosPage extends StatefulWidget {
  final List<dynamic> _photos;

  const AllPhotosPage(this._photos);

  @override
  AllPhotosPageState createState() => AllPhotosPageState();
}

class AllPhotosPageState extends State<AllPhotosPage> {
  void showPhoto(index) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey),
          actions: <Widget>[
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: Text('Share'),
                )
              ],
              onSelected: (v) {
                //  gridPhotoViewer.takeScreenShot();
              },
            )
          ],
        ),
        body: SizedBox.expand(
          child: CarouselSlider(
            autoPlay: false,
            viewportFraction: 1.0,
            aspectRatio: MediaQuery.of(context).size.aspectRatio,
            enableInfiniteScroll: false,
            items: widget._photos.map(
              (aPhoto) {
                var photo = Photo(
                    assetName: aPhoto['file_url'],
                    title: aPhoto['file_name'],
                    caption: aPhoto['caption']);
                return GridPhotoViewer(photo: photo);
              },
            ).toList(),
            initialPage: index,
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: 1,),
                  itemBuilder: (BuildContext context, int index){
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          showPhoto(index);
                        },
                        child: CachedNetworkImage(
                          imageUrl:widget._photos[index]['file_url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }, itemCount: widget._photos.length,)
              ,
            ),
          ),
        ],
      ),
    );
  }
}
