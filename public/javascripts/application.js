
function populate_select(target, options_array, minimum_length) {
  if (options_array != null) {
    target.options.length = minimum_length;
    for (var i = 0; i < options_array.length; i++) {
      target.options[target.options.length] = new Option(options_array[i][1], options_array[i][0]);
    }
  } else {
    target.options.length = minimum_length;
    target.selectedIndex = 0;
  }
}

function add_tag(from, to) {
  tags_select = $(from);
  tags = $(to);
  if (tags_select.options[tags_select.selectedIndex].value == '----') {
  } else if (tags.value == '') {
    tags.value = tags_select.options[tags_select.selectedIndex].value;
  }  else {
    tags.value = tags.value + ', ' + tags_select.options[tags_select.selectedIndex].value;
  }
}

function clear_field(field_name) {
  $(field_name).value = '';
}

function hide_show_div(div_id, class_name) {
  e = $(div_id)
  if (e.className.match(/hide$/)) {
    e.className=class_name;
  } else {
    e.className = 'hide';
  }
}

function retrieve_or_hide(link, element) {
  link.blur();
  e = $(element)
  if (e.className.match(/hide$/)) {
    return true;
  } else {
    e.className = 'hide';
    return false;
  }
}

function replace_with_spinner(container, spinner_image_url) {
  $(container).innerHTML = "<img class='spinner' title='loading...' src='" + spinner_image_url + "'/>";
}

function change_check_boxes(checked, form_name) {
  e = $(form_name);
  for (i = 0; i < e.length; i++) {
    if (e.elements[i].type == 'checkbox') {
      e.elements[i].checked = checked;
    }
  }
}

function add_text(text, target) {
  e = $(target);
  e.value = e.value + text;
  e.focus();
}

function surround_text(text1, text2, target) {
  e = $(target);
  if (typeof(e.caretPos) != 'undefined' && e.createTextRange) {
    var caret_pos = e.caretPos;
    caret_pos.text = caret_pos.text.charAt(caret_pos.text.length - 1) == ' ' ? text1 + caret_pos.text + text2 + ' ' : text1 + caret_pos.text + text2;
    caret_pos.select();
  } else if (typeof(e.selectionStart) != 'undefined') {
    var begin = e.value.substr(0, e.selectionStart);
    var selection = e.value.substr(e.selectionStart, e.selectionEnd - e.selectionStart);
    var end = e.value.substr(e.selectionEnd);
    var new_cursor_pos = e.selectionStart;
    var scroll_pos = e.scrollTop;
    e.value = begin + text1 + selection + text2 + end;
    if (e.setSelectionRange) {
      if (selection.length == 0)
        e.setSelectionRange(new_cursor_pos + text1.length, new_cursor_pos + text1.length);
      else
        e.setSelectionRange(new_cursor_pos, new_cursor_pos + text1.length + selection.length + text2.length);
      e.focus();
    }
    e.scrollTop = scroll_pos;
  } else {
    e.value += text1 + text2;
    e.focus(e.value.length - 1);
  }
}

function insert_text(text, target) {
  e = $(target);
  if (typeof(e.caretPos) != 'undefined' && e.createTextRange) {
    var caret_pos = e.caretPos;
    caret_pos.text = text;
    caret_pos.select();
  } else if (typeof(e.selectionStart) != 'undefined') {
    var begin = e.value.substr(0, e.selectionStart);
    var selection = e.value.substr(e.selectionStart, e.selectionEnd - e.selectionStart);
    var end = e.value.substr(e.selectionEnd);
    var newCursorPos = e.selectionStart;
    var scrollPos = e.scrollTop;
    e.value = begin + text + end;
    if (e.setSelectionRange) {
      if (selection.length == 0)
        e.setSelectionRange(newCursorPos + text.length, newCursorPos + text.length);
      else
        e.setSelectionRange(newCursorPos, newCursorPos + text);
      e.focus();
    }
    e.scrollTop = scrollPos;
  } else {
    e.value += text;
    e.focus(e.value.length - 1);
  }
}
