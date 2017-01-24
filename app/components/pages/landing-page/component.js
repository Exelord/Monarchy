import Ember from 'ember';

const { Component } = Ember;

export default Component.extend({
  init() {
    this._super(...arguments);

    if (isMobile.any) {
      this.get('classNames').push('mobile-browser')
    }
  }
});
