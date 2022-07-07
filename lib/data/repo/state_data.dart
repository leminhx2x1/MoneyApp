class StateData<T> {
  T? data;
  Exception? e;
  bool get isHasData => this.data !=null;
  StateData.success(this.data);
  StateData.error(this.e);
}
