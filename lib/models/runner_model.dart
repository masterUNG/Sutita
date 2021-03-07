class RunnerModel {
  String daterunner;
  String distance;
  String timerunner;
  String typerunner;

  RunnerModel(
      {this.daterunner, this.distance, this.timerunner, this.typerunner});

  RunnerModel.fromJson(Map<String, dynamic> json) {
    daterunner = json['daterunner'];
    distance = json['distance'];
    timerunner = json['timerunner'];
    typerunner = json['typerunner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['daterunner'] = this.daterunner;
    data['distance'] = this.distance;
    data['timerunner'] = this.timerunner;
    data['typerunner'] = this.typerunner;
    return data;
  }
}

