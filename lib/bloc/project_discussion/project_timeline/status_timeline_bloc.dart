import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../api_helper/api.dart';
import '../../../data/model/project/status_timeline.dart';
import '../../../data/repositories/Project/project_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

part 'status_timeline_event.dart';
part 'status_timeline_state.dart';

class StatusTimelineBloc extends Bloc<StatusTimelineEvent, StatusTimelineState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;

  StatusTimelineBloc() : super(StatusTimelineInitial()) {

    on<StatusTimelineList>(_getStatausTimelineLists);
    // on<DeleteProjectMedia>(_deleteProjectMedia);

    }
  Future<void> _getStatausTimelineLists(
      StatusTimelineList event, Emitter<StatusTimelineState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;

        emit(ProjectStatusTimelineLoading());

      List<StatusTimelineModel> timeline = [];
      Map<String, dynamic> result = await ProjectRepo().getProjectTimeLineStatus(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',


      );
      timeline = List<StatusTimelineModel>.from(
          result['data'].map((projectData) => StatusTimelineModel.fromJson(projectData)));
      if (event.id != null) {
        _offset = 0;
      } else {
        _offset += _limit;
      }
      print("fdfdzgg dfesres ");
      _hasReachedMax = timeline.length >= result['total'];

      if (result['error'] == false) {
        emit(ProjectStatusTimelinePaginated(
          ProjectTimeline: timeline,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectStatusTimelineError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectStatusTimelineError("Error: $e")));
    }
  }
}
