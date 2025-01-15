/**
 * @description  : Utility component for LWR portal.
 **/
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ToastContainer from "lightning/toastContainer";
import NWCompassPortal_Suffix from "@salesforce/label/c.NWCompassPortal_Suffix";
import MonthsLabel from '@salesforce/label/c.Months';
/*
 * @description : Used to initialize the toast container for LWR.
 */
export function initToast(maxShown = 1, toastPosition = "top-center") {
  const toastContainer = ToastContainer.instance();
  toastContainer.maxShown = maxShown;
  toastContainer.toastPosition = toastPosition;
}

/*
 * @description : Used to fire a toast message for LWR.
 */
export function showToastMsg(
  instance,
  title,
  msg,
  variant,
  doInitToast = true
) {
  if (doInitToast) {
    initToast();
  }
  const evt = new ShowToastEvent({
    title: title,
    message: msg,
    variant: variant
  });
  instance.dispatchEvent(evt);
}

/*
 * @description : method to validate email.
 */
export function isValidEmail(email) {
  const regEmail = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  return regEmail.test(email);
}

/*
 * @description : returns true if string is null, empty or blank.
 */
export function isEmpty(str) {
  return !str || str.trim().length === 0;
}

/*
 * @description : returns formatted string. Used in toastNotification lwc
 */
export function replaceStrings(str, mapObj) {
  if (str && mapObj && Object.keys(mapObj).length) {
    const re = new RegExp(Object.keys(mapObj).join("|"), "gi");
    return str.replace(re, function (matched) {
      return mapObj[matched];
    });
  }
  return str;
}

/*
 * @description : returns string after adding all attributes to anchor tag.
 */
export function addClassToAllAnchorTags(str, attribute) {
  if (str && attribute) {
    const re = new RegExp("<s*\\n*a", "gi");
    return str.replaceAll(re, "<a " + attribute);
  }
  return str;
}

/*
 * @description : returns string month name from date object.
 */
export function getMonthFromDate(date) {
  if (!date) {
    return "";
  }
  const months = MonthsLabel.split(','); 
  return months[date.getMonth()];
}

/*
 * @description : returns string month name from UTC date.
 */
export function getMonthNameFromUtcDate(utcDate) {
  if (isEmpty(utcDate)) {
    return "";
  }
  return getMonthFromDate(new Date(utcDate));
}

/*
 * @description : returns string month name and year eg: "May 2024" from UTC date.
 */
export function getMonthNameAndYearFromUtcDate(utcDate) {
  if (isEmpty(utcDate)) {
    return "";
  }
  return (
    getMonthFromDate(new Date(utcDate)) + " " + new Date(utcDate).getFullYear()
  );
}

/*
 * @description : sorts the array by month using given month number field.
 */
export function sortByMonth(dataList, monthNumField) {
  const months = [
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
    "December",
    ""
  ];
  dataList.sort(function (a, b) {
    return months.indexOf(a[monthNumField]) - months.indexOf(b[monthNumField]);
  });
  return dataList;
}

/*
 * @description : sorts the array by month using given month number and year field.
 */
export function sortByMonthAndYear(array, monthNumField, yearField) {
  const months = [
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
    "December",
    ""
  ];
  const sorter = (a, b) => {
    return a[yearField] !== b[yearField]
      ? a[yearField] - b[yearField]
      : a[monthNumField] - b[monthNumField];
  };
  array.sort(sorter);
  return array;
}

export function formatDate(dateVal) {
  var newDate = new Date(dateVal);

  var sMonth = padValue(newDate.getMonth() + 1);
  var sDay = padValue(newDate.getDate());
  var sYear = newDate.getFullYear();
  var sHour = newDate.getHours();
  var sMinute = padValue(newDate.getMinutes());
  var sAMPM = "AM";

  var iHourCheck = parseInt(sHour);

  if (iHourCheck > 12) {
    sAMPM = "PM";
    sHour = iHourCheck - 12;
  } else if (iHourCheck === 0) {
    sHour = "12";
  }

  sHour = padValue(sHour);

  return (
    sMonth +
    "/" +
    sDay +
    "/" +
    sYear +
    " " +
    sHour +
    ":" +
    sMinute +
    " " +
    sAMPM
  );
}

export function isEmptyObject(obj) {
  for (const prop in obj) {
    if (Object.hasOwn(obj, prop)) {
      return false;
    }
  }
  return true;
}

export function getFullName(contact) {
  const { FirstName, LastName, MiddleName } = contact;
  const firstName = FirstName ? FirstName : "";
  const middleName = MiddleName ? MiddleName : "";
  const lastName = LastName ? LastName : "";
  const fullName = `${firstName} ${middleName} ${lastName}`.trim();
  return fullName;
}

export function generateUniqueId() {
  return Math.floor(1000000000 + Math.random() * 9000000000).toString();
}

/*This method checks if a given phone number consists of exactly 10 digits, indicating its validity. */
export function isValidPhoneNumber(phoneNumber) {
  return /^\d{10}$/.test(phoneNumber);
}

/*  checks if a given value is not empty, not blank, not null, and not undefined, 
  returning true if it passes all conditions, and false otherwise. */
export function isValidValue(value) {
  if (value !== "" && value !== null && value !== undefined) {
    const trimmedValue = value.trim();
    if (trimmedValue !== "") {
      return true;
    }
  }
  return false;
}

/*This method formats a given phone number into a standard format with parentheses for the area code, 
    a space, and a dash for the main number.*/
export function formatPhoneNumber(phoneNumber) {
  if (!phoneNumber) {
    return "";
  }
  const formattedNumber = phoneNumber.replace(
    /(\d{3})(\d{3})(\d{4})/,
    "($1) $2-$3"
  );
  return formattedNumber;
}

export function isValidateZIPPostal(value) {
  if (!value.match(/^[0-9]+$/) || value.length < 5) {
    return true;
  }
  return false;
}

export function getSuffixOptions(value) {
  return NWCompassPortal_Suffix.split(",").map((item) => ({
    label: item,
    value: item
  }));
}

function padValue(value) {
  return value < 10 ? "0" + value : value;
}

/*
 * @description : format Start and end datetime in MM/DD/YYYY HH:MM - HH:MM if the date belongs to same date,
 *  othewise format it to MM/DD/YYYY HH:MM - MM/DD/YYYY HH:MM if date is different
 */
export function formatStartEndDateTime(start, end) {
  const startDate = new Date(start);
  const endDate = new Date(end);

  const pad = (num) => num.toString().padStart(2, "0");

  const startMonth = pad(startDate.getMonth() + 1);
  const startDay = pad(startDate.getDate());
  const startYear = startDate.getFullYear();
  const startHours = startDate.getHours();
  const startMinutes = pad(startDate.getMinutes());
  const startPeriod = startHours >= 12 ? "PM" : "AM";
  const formattedStartHours = startHours % 12 || 12;

  const endMonth = pad(endDate.getMonth() + 1);
  const endDay = pad(endDate.getDate());
  const endYear = endDate.getFullYear();
  const endHours = endDate.getHours();
  const endMinutes = pad(endDate.getMinutes());
  const endPeriod = endHours >= 12 ? "PM" : "AM";
  const formattedEndHours = endHours % 12 || 12;

  if (startYear === endYear && startMonth === endMonth && startDay === endDay) {
    return `${startMonth}/${startDay}/${startYear} ${formattedStartHours}:${startMinutes} ${startPeriod} - ${formattedEndHours}:${endMinutes} ${endPeriod}`;
  }
  return `${startMonth}/${startDay}/${startYear} ${formattedStartHours}:${startMinutes} ${startPeriod} - ${endMonth}/${endDay}/${endYear} ${formattedEndHours}:${endMinutes} ${endPeriod}`;
}

/*
 * @description : method to convert 'page=1&size=2' into JSON like { "page":1, "size": 2}
 */
export function queryStringToJSON(queryString) {
  // Split the query string by '&' to get each key-value pair
  const pairs = queryString.split("&");

  // Initialize an empty object to hold the key-value pairs
  const result = {};

  // Iterate over each pair
  pairs.forEach((pair) => {
    // Split each pair by '=' to separate the key and value
    const [key, value] = pair.split("=");

    // Convert the value to a number if it is a valid number
    const numericValue = isNaN(value) ? value : Number(value);

    // Assign the key-value pair to the result object
    result[key] = numericValue;
  });

  return result;
}
/*
Converts an ISO 8601 datetime string into a formatted date string in "MM/DD/YYYY" format. Returns an empty string if the input datetime is null, undefined, not a string, or blank.
 */
export function convertDateFormat(datetime) {
  if (!datetime || typeof datetime !== "string" || datetime.trim() === "") {
    return ""; // Return blank value if datetime is null, undefined, not a string, or blank
  }
  // Create a Date object from the ISO 8601 datetime string
  let dateObj = new Date(datetime);
  // Extract year, month, and day from the Date object
  let year = dateObj.getFullYear();
  let month = ("0" + (dateObj.getMonth() + 1)).slice(-2); // Months are zero based
  let day = ("0" + dateObj.getDate()).slice(-2);

  // Format the date as MM/DD/YYYY
  let formattedDate = `${month}/${day}/${year}`;

  return formattedDate;
}

export function formatString(template, ...params) {
  return template.replace(/{(\d+)}/g, function (match, number) {
    return typeof params[number] != "undefined" ? params[number] : match;
  });
}

export function getUTCDifferenceInSeconds(date1, date2) {
  // Parse the date strings to Date objects
  const d1 = new Date(date1);
  const d2 = new Date(date2);

  // Get the time difference in milliseconds
  const diffInMs = Math.abs(d1 - d2);

  // Convert milliseconds to seconds
  const diffInSeconds = diffInMs / 1000;

  return diffInSeconds;
}

export function capitalizeWords(sentence) {
  if (!sentence) return "";
  // Split the sentence into words
  let words = sentence.split(" ");

  // Capitalize the first letter of each word
  for (let i = 0; i < words.length; i++) {
    words[i] =
      words[i].charAt(0).toUpperCase() + words[i].slice(1).toLowerCase();
  }

  // Join the words back into a sentence
  return words.join(" ");
}