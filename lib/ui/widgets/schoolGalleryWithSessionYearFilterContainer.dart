import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/schoolGalleryCubit.dart';
import 'package:eschool/cubits/schoolSessionYearsCubit.dart';
import 'package:eschool/data/models/sessionYear.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SchoolGalleryWithSessionYearFilterContainer extends StatefulWidget {
  final Student student;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  const SchoolGalleryWithSessionYearFilterContainer({
    super.key,
    required this.student,
    required this.showBackButton,
    this.onBackPressed,
  });

  @override
  State<SchoolGalleryWithSessionYearFilterContainer> createState() =>
      _SchoolGalleryWithSessionYearFilterContainerState();
}

class _SchoolGalleryWithSessionYearFilterContainerState
    extends State<SchoolGalleryWithSessionYearFilterContainer> {
  SessionYear selectedSessionYear = SessionYear();
  List<SessionYear> sessionYears = [];

  // Added state to control the custom dropdown visibility
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchSessionYears();
    });
  }

  void fetchSessionYears() {
    context.read<SchoolSessionYearsCubit>().fetchSessionYears(
        useParentApi: context.read<AuthCubit>().isParent(),
        childId: widget.student.id ?? 0);
  }

  void fetchSchoolGallerySessionYearWise() {
    context.read<SchoolGalleryCubit>().fetchSchoolGallery(
        useParentApi: context.read<AuthCubit>().isParent(),
        sessionYearId: selectedSessionYear.id ?? 0);
  }

  void _handleBackNavigation() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!.call();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Get.back();
  }

  Widget _buildSessionYearDropDown() {
    final sessionYearNameTextStyle =
    TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.primary);

    return BlocConsumer<SchoolSessionYearsCubit, SchoolSessionYearsState>(
      listener: (context, state) {
        if (state is SchoolSessionYearsFetchSuccess) {
          sessionYears = state.sessionYears;
          if (sessionYears.isNotEmpty) {
            selectedSessionYear = sessionYears.firstWhere(
                    (element) => element.isDefault == 1,
                orElse: () => sessionYears.first);
          }
          setState(() {});
          fetchSchoolGallerySessionYearWise();
        }
      },
      builder: (context, state) {
        // Failure State
        if (state is SchoolSessionYearsFetchFailure) {
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: Utils.screenContentHorizontalPadding),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.32),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Utils.getTranslatedLabel(failedToGetSessionYearsKey),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                IconButton(
                  onPressed: fetchSessionYears,
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              ],
            ),
          );
        }

        // Loading State
        if (state is! SchoolSessionYearsFetchSuccess) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: Utils.screenContentHorizontalPadding),
            height: 50.0,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.32),
            ),
            child: Text(
              Utils.getTranslatedLabel(fetchingSessionYearsKey),
              style: sessionYearNameTextStyle,
            ),
          );
        }

        // Success State: Custom Expandable Dropdown
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The Trigger Button
            InkWell(
              onTap: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: Utils.screenContentHorizontalPadding),
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.0),
                    bottom: _isDropdownOpen ? Radius.zero : Radius.circular(10.0),
                  ),
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedSessionYear.name ?? "",
                        style: sessionYearNameTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _isDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            // 2. The Dropdown List (Only visible when open)
            if (_isDropdownOpen && sessionYears.isNotEmpty)
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.0)),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: sessionYears.length,
                  itemBuilder: (context, index) {
                    final sessionYear = sessionYears[index];
                    final isSelected = selectedSessionYear.id == sessionYear.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedSessionYear = sessionYear;
                          _isDropdownOpen = false; // Close after selection
                        });
                        fetchSchoolGallerySessionYearWise();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Utils.screenContentHorizontalPadding,
                          vertical: 16,
                        ),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sessionYear.name ?? "",
                                style: sessionYearNameTextStyle.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      heightPercentage: Utils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.showBackButton
              ? CustomBackButton(onTap: _handleBackNavigation)
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              Utils.getTranslatedLabel(galleryKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: Utils.screenTitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarSmallerHeightPercentage),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Utils.screenContentHorizontalPadding),
              child: _buildSessionYearDropDown(),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: 80,
                    left: Utils.screenContentHorizontalPadding,
                    right: Utils.screenContentHorizontalPadding),
                child: BlocBuilder<SchoolGalleryCubit, SchoolGalleryState>(
                  builder: (context, state) {
                    if (state is SchoolGalleryFetchSuccess) {
                      if (state.gallery.isEmpty) {
                        return Center(
                          child: NoDataContainer(
                              titleKey: noGalleryDataAvailableForThisSessionKey),
                        );
                      }

                      return Column(
                        children: state.gallery.reversed.map((gallery) {
                          final photosAndVideosCountTextStyle = TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.65));
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.galleryDetails,
                                      arguments: {
                                        "gallery": gallery,
                                        "sessionYear": selectedSessionYear
                                      });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 175,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Utils.bottomSheetTopRadius),
                                    child: gallery.isThumbnailSvg()
                                        ? SvgPicture.network(
                                      gallery.thumbnail ?? "",
                                      fit: BoxFit.cover,
                                    )
                                        : CachedNetworkImage(
                                      imageUrl: gallery.thumbnail ?? "",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 5, top: 15),
                                child: Text(
                                  (gallery.title ?? ""),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.0,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                child: const SizedBox(),
                              ),
                              Row(
                                children: [
                                  Text(
                                    gallery.getImages().isNotEmpty
                                        ? "${gallery.getImages().length} ${Utils.getTranslatedLabel(gallery.getImages().length == 1 ? photoKey : photosKey)}"
                                        : "0 ${Utils.getTranslatedLabel(photoKey)}",
                                    style: photosAndVideosCountTextStyle,
                                  ),
                                  Text(
                                    "   |   ",
                                    style: photosAndVideosCountTextStyle,
                                  ),
                                  Text(
                                    gallery.getVideos().isNotEmpty
                                        ? "${gallery.getVideos().length} ${Utils.getTranslatedLabel(gallery.getVideos().length == 1 ? videoKey : videosKey)}"
                                        : "0 ${Utils.getTranslatedLabel(videoKey)}",
                                    style: photosAndVideosCountTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    }
                    if (state is SchoolGalleryFetchFailure) {
                      return Center(
                        child: ErrorContainer(
                          errorMessageCode: state.errorMessage,
                          onTapRetry: () {
                            fetchSchoolGallerySessionYearWise();
                          },
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * (0.3)),
                      child: Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildAppBar(),
        ),
      ],
    );
  }
}