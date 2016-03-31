class BaseController {
  dispatch(action) {
    if (this[action]) {
      return this[action]();
    }
  }
}
