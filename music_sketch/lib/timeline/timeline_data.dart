import 'timeline_times.dart';
abstract class TimelineDataFactry {
  List<List<TimelineElementData>> getDatas();
}

class TimelineElementData{
	TimelinePositionRange positionRange;
	dynamic info;

  TimelineElementData(this.positionRange, this.info);
}

class TimelineData<T>{
	late final List<List<TimelineElementData>> dataList;
	final TimelineDataFactry factry;
  
  TimelineData(this.factry, {List<List<TimelineElementData>>? dataList}){
    this.dataList = dataList ?? [];
  }

	void update(){
		List<List<TimelineElementData>> newDatas = factry.getDatas();
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