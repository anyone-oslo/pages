type ReadyHandlerFunc = () => void;

const readyHandlers: ReadyHandlerFunc[] = [];

const handleState = () => {
  if (["interactive", "complete"].indexOf(document.readyState) > -1) {
    while(readyHandlers.length > 0) {
      (readyHandlers.shift())();
    }
  }
};

class ReadyHandler {
  constructor () {
    document.onreadystatechange = handleState;
  }

  ready (handler: ReadyHandlerFunc) {
    readyHandlers.push(handler);
    handleState();
  }
}

export default new ReadyHandler();
