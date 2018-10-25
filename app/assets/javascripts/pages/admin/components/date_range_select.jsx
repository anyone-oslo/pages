class DateRangeSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      startsAt: this.parseDate(props.startsAt) || this.defaultDate(),
      endsAt:   this.parseDate(props.endsAt) || this.defaultDate(60),
      startTime: "",
      endTime:   ""
    };
    this.state.startTime = this.timeToString(this.state.startsAt);
    this.state.endTime = this.timeToString(this.state.endsAt);

    this.changeStartsAt = this.changeStartsAt.bind(this);
    this.changeEndsAt = this.changeEndsAt.bind(this);
  }

  changeStartsAt(options = {}) {
    let newDate = this.modifyDate(this.state.startsAt, options);
    this.setDates(
      newDate,
      new Date(this.state.endsAt.getTime() + (newDate - this.state.startsAt))
    );
  }

  changeEndsAt(options = {}) {
    let newDate = this.modifyDate(this.state.endsAt, options);
    this.setDates(this.state.startsAt, newDate);
  }

  defaultDate(offset = 0) {
    let coeff = 1000 * 60 * 60;
    return new Date(
      (Math.round((new Date()).getTime() / coeff) * coeff) + coeff +
             (1000 * 60 * offset)
    );
  }

  modifyDate(original, options = {}) {
    var newDate = new Date(original);
    if (options.hasOwnProperty("year")) {
      newDate.setFullYear(options.year);
    }
    if (options.hasOwnProperty("month")) {
      newDate.setMonth(options.month);
    }
    if (options.hasOwnProperty("date")) {
      newDate.setDate(options.date);
    }
    if (options.hasOwnProperty("time") &&
        options.time.match(/^[\d]{1,2}(:[\d]{1,2})?$/)) {
      newDate.setHours(options.time.split(":")[0]);
      newDate.setMinutes(options.time.split(":")[1] || 0);
    }
    return newDate;
  }

  parseDate(str) {
    if (!str) { return; }
    return new Date(str);
  }

  setDates(start, end) {
    if (end < start) {
      end = start;
    }
    this.setState({
      startsAt: start,
      endsAt: end,
      startTime: this.timeToString(start),
      endTime: this.timeToString(end)
    });
  }

  startsAtToString() {
    if (this.props.disabled) { return ""; }
    return this.state.startsAt.toJSON();
  }

  endsAtToString() {
    if (this.props.disabled) { return ""; }
    return this.state.endsAt.toJSON();
  }

  renderDateSelect(key, date, handleChange) {
    return (
      <div className="date-select">
        <select value={date.getMonth()}
                onChange={e => handleChange({ month: e.target.value })}
                disabled={this.props.disabled}>
          {this.monthOptions().map((m, i) => (
            <option key={key + "-month-" + i}
                    value={i}>{m}</option>
          ))}
        </select>
        <select value={date.getDate()}
                onChange={e => handleChange({ date: e.target.value })}
                disabled={this.props.disabled}>
          {this.dayOptions().map(d => (
            <option key={key + "-date-" + d}
                    value={d}>{d}</option>
          ))}
        </select>
        <select value={date.getFullYear()}
                onChange={e => handleChange({ year: e.target.value })}
                disabled={this.props.disabled}>
          {this.yearOptions().map(y => (
            <option key={key + "-year-" + y}
                    value={y}>{y}</option>
          ))}
        </select>
      </div>
    );
  }

  render() {
    return (
      <div className="date-range-select">
        <input type="hidden"
               name={this.props.objectName + "[starts_at]"}
               value={this.startsAtToString()} />
        <input type="hidden"
               name={this.props.objectName + "[ends_at]"}
               value={this.endsAtToString()} />
        <div className="date">
          {this.renderDateSelect("starts-at",
                                 this.state.startsAt,
                                 this.changeStartsAt)}
          {!this.props.disableTime && (
             <input type="text"
                    size="5"
                    value={this.state.startTime}
                    disabled={this.props.disabled}
                    onChange={e => this.setState({ startTime: e.target.value })}
                    onBlur={e => this.changeStartsAt({ time: e.target.value })} />
          )}
        </div>
        <span className="to">to</span>
        <div className="date">
          {this.renderDateSelect("ends-at",
                                 this.state.endsAt,
                                 this.changeEndsAt)}
          {!this.props.disableTime && (
             <input type="text"
                    size="5"
                    value={this.state.endTime}
                    disabled={this.props.disabled}
                    onChange={e => this.setState({ endTime: e.target.value })}
                    onBlur={e => this.changeEndsAt({ time: e.target.value })} />
          )}
        </div>
      </div>
    );
  }

  timeToString(time) {
    return time.toTimeString().slice(0, 5);
  }

  // Returns an array with years from 2000 to 10 years from now.
  yearOptions() {
    let start = 2000;
    return Array.apply(null, Array((new Date()).getFullYear() - start + 11))
                .map((_, i) => i + start);
  }

  monthOptions() {
    return(["January", "February", "March", "April", "May", "June", "July",
            "August", "September", "October", "November", "December"]);
  }

  dayOptions() {
    return Array.apply(null, Array(31)).map((_, i) => i + 1);
  }
}
