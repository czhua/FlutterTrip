import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/pages/search_page.dart';
import 'package:flutter_trip/widget/grid_nav.dart';
import 'package:flutter_trip/widget/loading_container.dart';
import 'package:flutter_trip/widget/local_nav.dart';
import 'package:flutter_trip/widget/sales_box_nav.dart';
import 'package:flutter_trip/widget/search_bar.dart';
import 'package:flutter_trip/widget/sub_nav.dart';
import 'package:flutter_trip/widget/web_view.dart';

const APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = '景点 酒店 美食';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double appBarAlpha = 0;
  List<CommonModel> localNavList = [];
  List<CommonModel> bannerList = [];
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = [];
  SalesBoxModel salesBoxModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
    print(appBarAlpha);
  }

  Future<Null> _handleRefresh() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
        bannerList = model.bannerList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBoxModel = model.salesBox;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: LoadingContainer(
          isLoading: _loading,
          child: Stack(
            children: <Widget>[
              MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: NotificationListener(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification &&
                            scrollNotification.depth == 0) {
                          _onScroll(scrollNotification.metrics.pixels);
                        }
                      },
                      child: _listView,
                    ),
                  )),
              _appBar,
            ],
          ),
        ));
  }

  Widget get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          child: LocalNav(
            localNavList: localNavList,
          ),
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: GridNav(
            gridNavModel: gridNavModel,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: SubNav(
            subNavList: subNavList,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: SalesBox(
            salesBox: salesBoxModel,
          ),
        ),
        Container(
          height: 800,
          child: ListTile(
            title: Text('ttt'),
          ),
        )
      ],
    );
  }

  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  CommonModel model = bannerList[index];
                  return WebView(
                      url: model.url,
                      title: model.title,
                      hideAppBar: model.hideAppBar);
                }));
              },
              child: Image.network(
                bannerList[index].icon,
                fit: BoxFit.fill,
              ));
        },
        pagination: SwiperPagination(),
      ),
    );
  }

  Widget get _appBar {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x66000000), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80.0,
            decoration: BoxDecoration(
              color: Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255),
            ),
            child: SearchBar(
              searchBarType: appBarAlpha > 0.2
                  ? SearchBarType.homeLight
                  : SearchBarType.home,
              inputBoxClick: _jumpToSearch,
              speakClick: _jumpToSpeak,
              defaultText: SEARCH_BAR_DEFAULT_TEXT,
              leftButtonClick: () {},
            ),
          ),
        ),
        Container(
          height: appBarAlpha > 0.2 ? 0.5 : 0,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)]),
        )
      ],
    );
  }

  _jumpToSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchPage(
        hint: SEARCH_BAR_DEFAULT_TEXT,
      );
    }));
  }

  _jumpToSpeak() {}
}
