import { initNav } from './js/navigation';
import { initSearch } from './js/search';
import { followHeader } from './js/header';
import { collapsableBreadcrumbs } from './js/breadcrumbs';

document.addEventListener('DOMContentLoaded', initNav);
document.addEventListener('DOMContentLoaded', initSearch);
document.addEventListener('DOMContentLoaded', followHeader);
document.addEventListener('DOMContentLoaded', collapsableBreadcrumbs);
