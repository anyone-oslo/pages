class FocalPoint extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dragging: false,
      x: props.x,
      y: props.y
    };
    this.dragStart = this.dragStart.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.drag = this.drag.bind(this);
    this.container = React.createRef();
    this.point = React.createRef();
  }

  clamp(val, min, max) {
    if (val < min) {
      return min;
    } else if (val > max) {
      return max;
    } else {
      return val;
    }
  }

  dragStart(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    if (evt.target == this.point.current) {
      this.setState({dragging: true});
    }
  }

  dragEnd() {
    if (this.state.dragging) {
      this.setState({dragging: false});
      this.props.onChange({x: this.state.x, y: this.state.y});
    }
  }

  drag(evt) {
    if (this.state.dragging) {
      let containerSize = this.container.current.getBoundingClientRect();
      var x , y;
      evt.preventDefault();

      if (evt.type == "touchmove") {
        x = evt.touches[0].clientX - (containerSize.x || containerSize.left);
        y = evt.touches[0].clientY - (containerSize.y || containerSize.top);
      } else {
        x = evt.clientX - (containerSize.x || containerSize.left);
        y = evt.clientY - (containerSize.y || containerSize.top);
      }

      x = this.clamp(x, 0, this.props.width);
      y = this.clamp(y, 0, this.props.height);

      this.setState({x: (x / this.props.width) * 100,
                     y: (y / this.props.height) * 100});
    }
  }

  render() {
    let x = this.props.width * (this.state.x / 100);
    let y = this.props.height * (this.state.y / 100);
    let pointStyle = {
      transform: `translate3d(${x}px, ${y}px, 0)`
    };
    return (
      <div className="focal-editor"
           ref={this.container}
           onTouchStart={this.dragStart}
           onTouchEnd={this.dragEnd}
           onTouchMove={this.drag}
           onMouseDown={this.dragStart}
           onMouseUp={this.dragEnd}
           onMouseMove={this.drag}>
        <div className="focal-point" style={pointStyle} ref={this.point} />
      </div>
    );
  }
}
