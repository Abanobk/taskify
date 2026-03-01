import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../api_helper/api.dart';
import '../../data/model/finance/unitd_model.dart';
import '../../data/repositories/units/units_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'unit_event.dart';
import 'unit_state.dart';

class UnitBloc extends Bloc<UnitsEvent, UnitsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 6;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingItem = "";

  UnitBloc() : super(UnitsInitial()) {
    on<CreateUnits>(_onUnitsCreate);
    on<UnitsList>(_getListOfUnits);
    on<AddUnits>(_onAddItem);
    on<UpdateUnits>(_onUpdateItem);
    on<DeleteUnits>(_onDeleteItem);
    on<SearchUnits>(_onSearchUnits);
    on<LoadMoreUnits>(_onLoadMoreUnits);
  }

  Future<void> _onUnitsCreate(CreateUnits event, Emitter<UnitsState> emit) async {
    try {
      emit(UnitsLoading());

      Map<String,dynamic> result = await UnitsRepo().createUnit(
          token: true,
          title: event.title,
          desc: event.desc,

         );

      if (result['error'] == false) {
        emit(const UnitsCreateSuccess());
        add(const UnitsList());
      }
      if (result['error'] == true) {
        emit((UnitsCreateError(result['message'])));
        add(const UnitsList());
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(UnitsError("Error: $e"));
    }
  }


  Future<void> _getListOfUnits(UnitsList event, Emitter<UnitsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(UnitsLoading());
      List<UnitModel> Units =[];
      Map<String,dynamic> result
      = await UnitsRepo().UnitList(limit: _limit, offset: _offset, search: '');
      Units = List<UnitModel>.from(result['data'].map((projectData) =>
          UnitModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Units.length < _limit;

      if (result['error'] == false) {
        emit(UnitsPaginated(Units: Units, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((UnitsError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(UnitsError("Error: $e"));
    }
  }
  Future<void> _onAddItem(AddUnits event, Emitter<UnitsState> emit) async {
    if (state is UnitsPaginated) {
      final Item = event.Units;
      final title = Item.title;
      final desc = Item.description;

      //
      try {
         emit(UnitsCreateSuccessLoading());

        Map<String,dynamic> result
    = await UnitsRepo().createUnit(
          title: title!,
          desc: desc!,
          token: true,
        );


        if (result['error'] == false) {

          emit(const UnitsCreateSuccess());
          add(const UnitsList());}
        if (result['error'] == true) {
          emit((UnitsCreateError(result['message'])));
          add(const UnitsList());
          flutterToastCustom(msg: result['message']);
        }


      } catch (e) {
        print('Error while creating Item: $e');
        // Optionally, handle the error state
      }
    }
  }
  void _onUpdateItem(UpdateUnits event, Emitter<UnitsState> emit) async {
    if (state is UnitsPaginated) {
      final Item = event.Units;
      final id = Item.id;
      final title = Item.title;
      final desc = Item.description;


      // Update the Item in the list
      try {


        emit(UnitsEditSuccessLoading());
        Map<String,dynamic> result = await UnitsRepo().updateUnit(
          id: id!,
          title: title!,
          desc: desc!,

        ) ; // Cast to UnitsModel

        // Replace the Item in the list with the updated one
        if (result['error'] == false) {
          emit(const UnitsEditSuccess());
          add(const UnitsList());


        }
        if (result['error'] == true) {
          emit((UnitsEditError(result['message'])));
          add(const UnitsList());
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((UnitsEditError("$e")));

        print('Error while updating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteItem(DeleteUnits event, Emitter<UnitsState> emit) async {
    // if (emit is UnitsSuccess) {
    final Item = event.Units;
    try {
      Map<String,dynamic> result
    =  await UnitsRepo().deleteUnit(
        id: Item,
        token: true,
      );
      if(result['error']== false) {
        emit(const UnitsDeleteSuccess());
        add(const UnitsList());
      }
      if(result['error'] == true){
        emit(UnitsDeleteError(result['message']));
        add(const UnitsList());
      }
    } catch (e) {
      emit(UnitsDeleteError(e.toString()));
      add(const UnitsList());
    }
    // }
  }

  Future<void> _onSearchUnits(
      SearchUnits event, Emitter<UnitsState> emit) async {
    try {
      emit(UnitsLoading());
      List<UnitModel> Units =[];
      Map<String,dynamic> result = await UnitsRepo()
          .UnitList(limit: _limit, offset: 0, search: event.searchQuery);
      Units = List<UnitModel>.from(result['data']
          .map((projectData) => UnitModel.fromJson(projectData)));
      bool hasReachedMax = Units.length < _limit;
      if (result['error'] == false) {
        emit(UnitsPaginated(Units:Units,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((UnitsError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(UnitsError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreUnits(
      LoadMoreUnits event, Emitter<UnitsState> emit) async {
    if (state is UnitsPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as UnitsPaginated;
        final updatedUnits = List<UnitModel>.from(currentState.Units);

        List<UnitModel> additionalUnits = [];
        Map<String, dynamic> result = await UnitsRepo().UnitList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalUnits = List<UnitModel>.from(
            result['data'].map((projectData) => UnitModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Units has been reached
        if (updatedUnits.length + additionalUnits.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Units to the updated list
        updatedUnits.addAll(additionalUnits);

        if (result['error'] == false) {
          emit(UnitsPaginated(Units: updatedUnits, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(UnitsError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(UnitsError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
