var Form_Attributes = {
    paired: [ 
	'action',
	'accept',
	'accept-charset',
	'enctype',
	'method',
	'target',
	'alt',
	'maxlength',
	'size',
	'value',
	'accesskey',
	'class',
	'dir',
	'lang',
	'style',
	'tabindex',
	'title',
	'onblur',
	'onchange',
	'onclick',
	'ondblclick',
	'onfocus',
	'onmousedown',
	'onmousemove',
	'onmouseout',
	'onmouseover',
	'onmouseup',
	'onkeydown',
	'onkeypress',
	'onkeyup',
	'onselect',
	'onreset',
	'cols',
	'rows'
    ],
    simple: [
	'checked',
	'disabled',
	'multiple',
	'readonly'
    ]
};

var Form = function(data) {
    for(var x in data) {
	this[x] = data[x];
    }
    if (!this.name) {
	this.name = 'form';
    }
    this.is_multipart = function() {
	return false;
    };
    this.field_attributes = function(prefix, field) {
	var id = prefix + '::' + field.name;
	var attrs = ' name="' + id + '" id="' + id + '"';
	return this.standard_attributes(attrs, field);
    };
    this.attributes = function() {
	var attrs = ' name="' + this.name + '" id="' + this.name + '"';
	if (this.is_multipart()) {
	    attrs += ' enctype="multipart/form-data"';
	}
	if (!this.method) {
	    this.method = 'POST';
	}
	return this.standard_attributes(attrs, this);
    };
    this.standard_attributes = function(attrs, field) {
	for(var x=0; x<Form_Attributes.paired.length; x++) {
	    var attr = Form_Attributes.paired[x];
	    if (field[attr]) {
		attrs += ' ' + attr + '="' + field[attr] + '"';
	    }
	}
	for(var x=0; x<Form_Attributes.simple.length; x++) {
	    var attr = Form_Attributes.simple[x];
	    if (field[attr]) {
		attrs += ' ' + attr;
	    }
	}
	return attrs;
    };
    $(this.container).html(JST['htdocs/scripts/templates/form/form']({ form: this }));
    var form = this;
    $(this.container + ' form[name=' + this.name + ']').submit(function(event) {
	alert('here - ' + form.name);
	return false;
    });
};
