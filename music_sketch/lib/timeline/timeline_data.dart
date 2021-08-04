import 'timeline_times.dart';
abstract class TimelineDataFactry<T> {
  List<List<TimelineElementData<T>>> getDatas();
}

class TimelineElementData<T>{
	TimelinePositionRange positionRange;
	T? info;

  TimelineElementData(this.positionRange, this.info);
}

class TimelineData<T>{
	late final List<List<TimelineElementData<T>>> dataList;
	final TimelineDataFactry<T> factry;
  
  TimelineData(this.factry, {List<List<TimelineElementData<T>>>? dataList}){
    this.dataList = dataList ?? [];
  }

	void update(){
		List<List<TimelineElementData<T>>> newDatas = factry.getDatas();
		int newLength = newDatas.length;
    
    while(dataList.length < newLength){
      dataList.add([]);
    }

    while(dataList.length > newLength){
      dataList.removeLast();
    }

		for(int i = 0; i < newLength; i++){
			var data = dataList[i];
      var newData = newDatas[i];
			data.clear();
			data.addAll(newData);
		}
	}
}