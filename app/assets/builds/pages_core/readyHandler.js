(() => {
  // app/javascript/readyHandler.js
  var readyHandlers = [];
  var handleState = () => {
    if (["interactive", "complete"].indexOf(document.readyState) > -1) {
      while (readyHandlers.length > 0) {
        readyHandlers.shift()();
      }
    }
  };
  var ReadyHandler = class {
    constructor() {
      document.onreadystatechange = handleState;
    }
    ready(handler) {
      readyHandlers.push(handler);
      handleState();
    }
  };
  var readyHandler_default = new ReadyHandler();
})();
