import React, { useState } from "react";
import PropTypes from "prop-types";

import DateTimeSelect from "./DateTimeSelect";

function defaultDate(offset = 0) {
  let coeff = 1000 * 60 * 60;
  return new Date(
    (Math.round((new Date()).getTime() / coeff) * coeff) + coeff +
      (1000 * 60 * offset)
  );
}

function parseDate(str) {
  if (!str) { return null; }
  return new Date(str);
}

export default function DateRangeSelect(props) {
  const { disabled, disableTime, objectName } = props;

  const [startsAt, setStartsAt] =
        useState(parseDate(props.startsAt) || defaultDate());
  const [endsAt, setEndsAt] =
        useState(parseDate(props.endsAt) || defaultDate(60));

  const setDates = (start, end) => {
    if (end < start) {
      end = start;
    }
    setStartsAt(start);
    setEndsAt(end);
  };

  const changeStartsAt = (newDate) => {
    setDates(newDate, new Date(endsAt.getTime() + (newDate - startsAt)));
  };

  const changeEndsAt = (newDate) => {
    setDates(startsAt, newDate);
  };

  return (
    <div className="date-range-select">
      <input type="hidden"
             name={objectName + "[starts_at]"}
             value={!disabled && startsAt.toJSON()} />
      <input type="hidden"
             name={objectName + "[ends_at]"}
             value={!disabled && endsAt.toJSON()} />
      <div className="date">
        <DateTimeSelect disabled={disabled}
                        disableTime={disableTime}
                        onChange={changeStartsAt}
                        value={startsAt} />
      </div>
      <span className="to">to</span>
      <div className="date">
        <DateTimeSelect disabled={disabled}
                        disableTime={disableTime}
                        onChange={changeEndsAt}
                        value={endsAt} />
      </div>
    </div>
  );
}

DateRangeSelect.propTypes = {
  startsAt: PropTypes.string,
  endsAt: PropTypes.string,
  disabled: PropTypes.bool,
  disableTime: PropTypes.bool,
  objectName: PropTypes.string
};
