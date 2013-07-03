// Generated by IcedCoffeeScript 1.4.0b
var CommonDialog,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

CommonDialog = (function() {

  function CommonDialog(name, types) {
    this.hide = __bind(this.hide, this);
    this.show = __bind(this.show, this);    this.dialog = $('#' + name);
    if (!this.dialog.length) {
      this.dialog = jQuery(tmpls.dialogs[name].dialog({
        types: types
      }));
      this.dialog.appendTo(App.$elem);
    }
  }

  CommonDialog.prototype.show = function() {
    return this.dialog.addClass('active');
  };

  CommonDialog.prototype.hide = function() {
    return this.dialog.removeClass('active');
  };

  return CommonDialog;

})();