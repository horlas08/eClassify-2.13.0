import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_filter.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';
import 'package:path/path.dart' as path;

class ItemRepository {
  factory ItemRepository() => _instance;

  ItemRepository._internal();

  static final ItemRepository _instance = ItemRepository._internal();

  Future<ItemModel> createItem(Map<String, dynamic> itemDetails) async {
    try {
      Map<String, dynamic> parameters = {};
      parameters.addAll(itemDetails);

      final galleryImagesList = parameters.remove("gallery_images") ?? [];

      if (galleryImagesList.isNotEmpty) {
        final images = List<Future<MultipartFile>>.empty(growable: true);

        for (final File image in galleryImagesList) {
          images.add(
            MultipartFile.fromFile(
              image.path,
              filename: path.basename(image.path),
            ),
          );
        }
        final multipartFiles = await Future.wait(images);
        parameters[Api.galleryImages] = multipartFiles;
      }

      parameters.addAll({Api.showOnlyToPremium: 1});

      Map<String, dynamic> response = await Api.post(
        url: Api.addItemApi,
        parameter: parameters,
      );

      return ItemModel.fromJson(response['data'][0]);
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchMyFeaturedItems({int? page}) async {
    try {
      Map<String, dynamic> parameters = {
        Api.status: "featured",
        Api.page: page,
      };

      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: itemList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchMyItems({
    String? getItemsWithStatus,
    int? page,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        if (getItemsWithStatus != null) Api.status: getItemsWithStatus,
        if (page != null) Api.page: page,
      };

      if (parameters[Api.status] == "") parameters.remove(Api.status);
      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: itemList,
      );
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemId(int id) async {
    Map<String, dynamic> parameters = {Api.id: id};

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> modelList = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemSlug(String slug) async {
    Map<String, dynamic> parameters = {Api.slug: slug};

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> modelList = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<Map> changeMyItemStatus({
    required int itemId,
    required String status,
    int? userId,
  }) async {
    Map response = await Api.post(
      url: Api.updateItemStatusApi,
      parameter: {
        Api.status: status,
        Api.itemId: itemId,
        if (userId != null) Api.soldTo: userId,
      },
    );
    return response;
  }

  Future<Map> createFeaturedAds({required int itemId}) async {
    Map response = await Api.post(
      url: Api.makeItemFeaturedApi,
      parameter: {Api.itemId: itemId},
    );
    return response;
  }

  Future<DataOutput<ItemModel>> fetchItemFromCatId({
    required int categoryId,
    required int page,
    LeafLocation? location,
    String? search,
    String? sortBy,
    ItemFilter? filter,
    int? excludedItemId,
  }) async {
    Map<String, dynamic> parameters = {
      Api.categoryId: categoryId,
      Api.page: page,
      Api.excludedItemId: ?excludedItemId,
    };

    if (filter != null) {
      parameters.addAll(filter.toJson);

      if (filter.customFields != null) {
        filter.customFields!.forEach((key, value) {
          if (value is List) {
            parameters[key] = value.map((v) => v.toString()).join(',');
          } else {
            parameters[key] = value.toString();
          }
        });
      }
    } else if (location != null) {
      parameters.addAll(location.toApiJson());
    }

    if (search != null) {
      parameters[Api.search] = search;
    }

    if (sortBy != null) {
      parameters[Api.sortBy] = sortBy;
    }

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<DataOutput<ItemModel>> fetchPopularItems({
    required String sortBy,
    required int page,
    required LeafLocation? location,
  }) async {
    Map<String, dynamic> parameters = {
      Api.sortBy: sortBy,
      Api.page: page,
      ...?location?.toApiJson(),
    };

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<ItemModel> editItem(Map<String, dynamic> itemDetails) async {
    Map<String, dynamic> parameters = {};
    parameters.addAll(itemDetails);

    final galleryImagesList = parameters.remove("gallery_images") ?? [];

    if (galleryImagesList.isNotEmpty) {
      final images = List.empty(growable: true);

      for (final image in galleryImagesList) {
        if (image is! File) {
          images.add(image);
        } else {
          images.add(
            await MultipartFile.fromFile(
              image.path,
              filename: path.basename(image.path),
            ),
          );
        }
      }
      parameters[Api.galleryImages] = images;
    }

    if (itemDetails.containsKey('translations')) {
      parameters['translations'] = itemDetails['translations'];
    }
    if (itemDetails.containsKey('custom_field_translations')) {
      parameters['custom_field_translations'] =
          itemDetails['custom_field_translations'];
    }

    Map<String, dynamic> response = await Api.post(
      url: Api.updateItemApi,
      parameter: parameters,
    );

    return ItemModel.fromJson(response['data'][0]);
  }

  Future<void> deleteItem({int? id, Iterable<int>? ids}) async {
    assert(
      (id != null) ^ (ids != null),
      "Either id or ids should be present but not both",
    );
    Map<String, dynamic> parameters = {};
    if (id != null) {
      parameters[Api.itemId] = id;
    } else {
      parameters[Api.itemIds] = ids!.join(",");
    }
    await Api.post(url: Api.deleteItemApi, parameter: parameters);
  }

  Future<void> itemTotalClick(int id) async {
    await Api.post(url: Api.setItemTotalClickApi, parameter: {Api.itemId: id});
  }

  Future<Json> makeAnOfferItem(int id, double? amount) async {
    try {
      final response = await Api.post(
        url: Api.itemOfferApi,
        parameter: {Api.itemId: id, Api.amount: ?amount},
      );

      final responseMap = response['data'] as Json;
      final itemMap = responseMap.remove('item');
      itemMap['formatted_price'] = responseMap['item_formatted_price'];

      final user = Chat.fromJson({
        ...response['data'] as Json,
        'item': itemMap,
        'last_message_time': response['data']['updated_at'] as String,
        'item_id': int.parse(response['data']['item_id'].toString()),
        'formatted_amount':
            response['data']['item_offer_formatted_amount'] as String?,
      });

      return {'message': response['message'] as String, 'data': user};
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> searchItem(
    String query,
    ItemFilter? filter, {
    required int page,
  }) async {
    Map<String, dynamic> parameters = {
      Api.search: query,
      Api.page: page,
      if (filter != null) ...filter.toJson,
    };

    if (filter != null) {
      parameters.remove(Api.area);
      if (filter.customFields != null) {
        parameters.addAll(filter.customFields!);
      }
    }

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<Json> getItem({required ItemMetaData metadata, int page = 1}) async {
    try {
      final response = await Api.get(
        url: Api.getItemApi,
        queryParameters: {...metadata.toJson, Api.page: page},
      );

      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemModel.fromJson,
      );

      final hasMore = items.length == response['data']['per_page'] as int;

      return {'data': items, 'has_more': hasMore};
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getItem');
      log('$stack', name: 'getItem');
      throw ApiException(e.toString());
    }
  }

  Future<ItemStatus> getItemStatus({required int itemId}) async {
    try {
      final response = await Api.get(
        url: Api.getItemStatusApi,
        queryParameters: {'item_id': itemId},
      );

      final status = ItemStatus.parse(response['data']['status'] as String);

      return status;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      return ItemStatus.unknown;
    }
  }
}
