class PageDates extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      has_dates: (props.starts_at ? true : false),
      starts_at: this.parseDate(props.starts_at) || this.defaultDate(),
      ends_at:   this.parseDate(props.ends_at) || this.defaultDate(60),
      all_day:   !!props.all_day,
      startTime: "",
      endTime:   ""
    };
    this.state.startTime = this.timeToString(this.state.starts_at);
    this.state.endTime = this.timeToString(this.state.ends_at);

    this.toggleAllDay = this.toggleAllDay.bind(this);
    this.toggleHasDates = this.toggleHasDates.bind(this);
    this.changeStartsAt = this.changeStartsAt.bind(this);
    this.changeEndsAt = this.changeEndsAt.bind(this);
  }

  defaultDate(offset = 0) {
    let coeff = 1000 * 60 * 60;
    return new Date(
      (Math.round((new Date()).getTime() / coeff) * coeff) + coeff +
           (1000 * 60 * offset)
    );
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
      starts_at: start,
      ends_at: end,
      startTime: this.timeToString(start),
      endTime: this.timeToString(end)
    });
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

  changeStartsAt(options = {}) {
    let newDate = this.modifyDate(this.state.starts_at, options);
    this.setDates(
      newDate,
      new Date(this.state.ends_at.getTime() + (newDate - this.state.starts_at))
    );
  }

  changeEndsAt(options = {}) {
    let newDate = this.modifyDate(this.state.ends_at, options);
    this.setDates(this.state.starts_at, newDate);
  }

  toggleHasDates() {
    this.setState({ has_dates: !this.state.has_dates });
  }

  toggleAllDay() {
    this.setState({ all_day: !this.state.all_day });
  }

  timeToString(time) {
    return time.toTimeString().slice(0, 5);
  }

  renderDateSelect(key, date, handleChange) {
    return (
      <div className="date-select">
        <select value={date.getMonth()}
                onChange={e => handleChange({ month: e.target.value })}
                disabled={!this.state.has_dates}>
          {this.monthOptions().map((m, i) => (
            <option key={key + "-month-" + i}
                    value={i}>{m}</option>
          ))}
        </select>
        <select value={date.getDate()}
                onChange={e => handleChange({ date: e.target.value })}
                disabled={!this.state.has_dates}>
          {this.dayOptions().map(d => (
            <option key={key + "-date-" + d}
                    value={d}>{d}</option>
          ))}
        </select>
        <select value={date.getFullYear()}
                onChange={e => handleChange({ year: e.target.value })}
                disabled={!this.state.has_dates}>
          {this.yearOptions().map(y => (
            <option key={key + "-year-" + y}
                    value={y}>{y}</option>
          ))}
        </select>
      </div>
    );
  }

  startsAtToString() {
    if (!this.state.has_dates) { return ""; }
    return this.state.starts_at.toJSON();
  }

  endsAtToString() {
    if (!this.state.has_dates) { return ""; }
    return this.state.ends_at.toJSON();
  }

  render() {
    return (
      <div className="page-dates field">
        <input type="hidden"
               name="page[all_day]"
               value={(this.state.has_dates && this.state.all_day) ? "1" : "0"} />
        <input type="hidden"
               name="page[starts_at]"
               value={this.startsAtToString()} />
        <input type="hidden"
               name="page[ends_at]"
               value={this.endsAtToString()} />
        <label>
          Dates
        </label>
        <div className="toggles">
          <label className="has-dates-toggle">
            <input type="checkbox"
                   checked={this.state.has_dates}
                   onChange={this.toggleHasDates} />
            Enabled
          </label>
          <label className={!this.state.has_dates && "disabled"}>
            <input type="checkbox"
                   disabled={!this.state.has_dates}
                   checked={this.state.all_day}
                   onChange={this.toggleAllDay} />
            All day event
          </label>
        </div>
        <div className="date">
          {this.renderDateSelect("starts-at",
                                 this.state.starts_at,
                                 this.changeStartsAt)}
          {!this.state.all_day && (
             <input type="text"
                    size="5"
                    value={this.state.startTime}
                    disabled={!this.state.has_dates}
                    onChange={e => this.setState({ startTime: e.target.value })}
                    onBlur={e => this.changeStartsAt({ time: e.target.value })} />
          )}
        </div>
        <span className="to">to</span>
        <div className="date">
          {this.renderDateSelect("ends-at",
                                 this.state.ends_at,
                                 this.changeEndsAt)}
          {!this.state.all_day && (
             <input type="text"
                    size="5"
                    value={this.state.endTime}
                    disabled={!this.state.has_dates}
                    onChange={e => this.setState({ endTime: e.target.value })}
                    onBlur={e => this.changeEndsAt({ time: e.target.value })} />
          )}
        </div>
      </div>
    );
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
