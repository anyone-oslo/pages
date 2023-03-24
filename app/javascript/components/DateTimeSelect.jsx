import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";

function modifyDate(original, options = {}) {
  var newDate = new Date(original);
  if (Object.prototype.hasOwnProperty.call(options, "year")) {
    newDate.setFullYear(options.year);
  }
  if (Object.prototype.hasOwnProperty.call(options, "month")) {
    newDate.setMonth(options.month);
  }
  if (Object.prototype.hasOwnProperty.call(options, "date")) {
    newDate.setDate(options.date);
  }
  if (Object.prototype.hasOwnProperty.call(options, "time") &&
      options.time.match(/^[\d]{1,2}(:[\d]{1,2})?$/)) {
    newDate.setHours(options.time.split(":")[0]);
    newDate.setMinutes(options.time.split(":")[1] || 0);
  }
  return newDate;
}

function timeToString(time) {
  return time.toTimeString().slice(0, 5);
}

// Returns an array with years from 2000 to 10 years from now.
function yearOptions() {
  let start = 2000;
  return Array.apply(null, Array((new Date()).getFullYear() - start + 11))
    .map((_, i) => i + start);
}

function monthOptions() {
  return(["January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December"]);
}

function dayOptions() {
  return Array.apply(null, Array(31)).map((_, i) => i + 1);
}

export default function DateTimeSelect(props) {
  const { disabled, disableTime, onChange, value } = props;

  const [timeString, setTimeString] = useState(timeToString(value));

  useEffect(() => {
    setTimeString(timeToString(value));
  }, [value]);

  const handleChange = (options = {}) => {
    onChange(modifyDate(value, options));
  };

  return (
    <div className="date-select">
      <select value={value.getMonth()}
              onChange={e => handleChange({ month: e.target.value })}
              disabled={disabled}>
        {monthOptions().map((m, i) => (
          <option key={i} value={i}>{m}</option>
        ))}
      </select>
      <select value={value.getDate()}
              onChange={e => handleChange({ date: e.target.value })}
              disabled={disabled}>
        {dayOptions().map(d => (
          <option key={d} value={d}>{d}</option>
        ))}
      </select>
      <select value={value.getFullYear()}
              onChange={e => handleChange({ year: e.target.value })}
              disabled={disabled}>
        {yearOptions().map(y => (
          <option key={y} value={y}>{y}</option>
        ))}
      </select>
      {!disableTime &&
       <input type="text"
              size={5}
              disabled={disabled}
              value={timeString}
              onChange={e => setTimeString(e.target.value)}
              onBlur={e => handleChange({ time: e.target.value })} />}
    </div>
  );
}

DateTimeSelect.propTypes = {
  disabled: PropTypes.bool,
  disableTime: PropTypes.bool,
  onChange: PropTypes.func,
  value: PropTypes.instanceOf(Date)
};
