class PageDates extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      has_dates: (props.starts_at ? true : false),
      all_day:   !!props.all_day
    };

    this.toggleAllDay = this.toggleAllDay.bind(this);
    this.toggleHasDates = this.toggleHasDates.bind(this);
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

  render() {
    return (
      <div className="page-dates field">
        <input type="hidden"
               name="page[all_day]"
               value={(this.state.has_dates && this.state.all_day) ? "1" : "0"} />
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
        <DateRangeSelect objectName="page"
                         startsAt={this.props.starts_at}
                         endsAt={this.props.ends_at}
                         disabled={!this.state.has_dates}
                         disableTime={this.state.all_day}
        />
      </div>
    );
  }
}
