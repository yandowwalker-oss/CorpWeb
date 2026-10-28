'use strict';

const nav = document.getElementById('main-nav');
const menu = document.querySelector('.menu-toggle');
const mobile = window.matchMedia('(max-width: 760px)');

function closeMenu(restoreFocus = false) {
  nav.classList.remove('open');
  menu.setAttribute('aria-expanded', 'false');
  if (restoreFocus) menu.focus();
}

menu.addEventListener('click', () => {
  const open = menu.getAttribute('aria-expanded') !== 'true';
  menu.setAttribute('aria-expanded', String(open));
  nav.classList.toggle('open', open);
});

nav.querySelectorAll('a').forEach(link => link.addEventListener('click', () => closeMenu()));
document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && menu.getAttribute('aria-expanded') === 'true') closeMenu(true);
});
document.addEventListener('click', event => {
  if (!event.target.closest('header')) closeMenu();
});
document.addEventListener('focusin', event => {
  if (!event.target.closest('header')) closeMenu();
});
mobile.addEventListener('change', () => {
  const focusWasInNav = nav.contains(document.activeElement);
  closeMenu(mobile.matches && focusWasInNav);
});
