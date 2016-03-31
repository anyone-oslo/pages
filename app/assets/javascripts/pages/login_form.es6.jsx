$(function () {
  $('.login-form').each(function () {
    let container = this;

    function showTab(tabName) {
      $(container).find('.login-tab').hide();
      $(container).find(`.login-tab.${tabName}`).show();
      return false
    }

    $(container).find('.show-password').click(function () {
      return showTab('password');
    });

    $(container).find('.show-password-reset').click(function () {
      return showTab('password-reset');
    });

    showTab('password');
  });
});
