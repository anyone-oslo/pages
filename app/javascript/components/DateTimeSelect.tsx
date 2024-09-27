import { useEffect, useState } from "react";

interface DateTimeSelectProps {
  name: string;
  onChange: (date: Date) => void;
  value: Date;
  disabled?: boolean;
  disableTime?: boolean;
}

interface ModifyOptions {
  year?: number;
  month?: number;
  date?: number;
  time?: string;
}

function modifyDate(original: Date, options: ModifyOptions = {}): Date {
  const newDate = new Date(original);
  if ("year" in options) {
    newDate.setFullYear(options.year);
  }
  if ("month" in options) {
    newDate.setMonth(options.month);
  }
  if ("date" in options) {
    newDate.setDate(options.date);
  }
  if ("time" in options && options.time.match(/^[\d]{1,2}(:[\d]{1,2})?$/)) {
    newDate.setHours(parseInt(options.time.split(":")[0], 10));
    newDate.setMinutes(parseInt(options.time.split(":")[1], 10) || 0);
  }
  return newDate;
}

function timeToString(time: Date): string {
  return time.toTimeString().slice(0, 5);
}

function yearOptions(year: number): number[] {
  const start = Math.min(new Date().getFullYear() - 100, year - 10);
  const end = Math.max(new Date().getFullYear() + 100, year + 10);
  const years: number[] = [];
  for (let i = start; i <= end; i++) {
    years.push(i);
  }
  return years;
}

function monthOptions(): string[] {
  return [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
}

function dayOptions(): number[] {
  const numbers: number[] = [];
  for (let i = 1; i <= 31; i++) {
    numbers.push(i);
  }
  return numbers;
}

export default function DateTimeSelect(props: DateTimeSelectProps) {
  const { name, disabled, disableTime, onChange, value } = props;

  const [timeString, setTimeString] = useState(timeToString(value));

  useEffect(() => {
    setTimeString(timeToString(value));
  }, [value]);

  const handleChange = (options = {}) => {
    onChange(modifyDate(value, options));
  };

  return (
    <div className="date-select">
      {name && (
        <input type="hidden" name={name} value={!disabled && value.toJSON()} />
      )}
      <select
        value={value.getMonth()}
        onChange={(e) => handleChange({ month: e.target.value })}
        disabled={disabled}>
        {monthOptions().map((m, i) => (
          <option key={i} value={i}>
            {m}
          </option>
        ))}
      </select>
      <select
        value={value.getDate()}
        onChange={(e) => handleChange({ date: e.target.value })}
        disabled={disabled}>
        {dayOptions().map((d) => (
          <option key={d} value={d}>
            {d}
          </option>
        ))}
      </select>
      <select
        value={value.getFullYear()}
        onChange={(e) => handleChange({ year: e.target.value })}
        disabled={disabled}>
        {yearOptions(value.getFullYear()).map((y) => (
          <option key={y} value={y}>
            {y}
          </option>
        ))}
      </select>
      {!disableTime && (
        <input
          className="time"
          type="text"
          size={5}
          disabled={disabled}
          value={timeString}
          onChange={(e) => setTimeString(e.target.value)}
          onBlur={(e) => handleChange({ time: e.target.value })}
        />
      )}
    </div>
  );
}
