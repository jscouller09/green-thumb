import "bootstrap";
import { initAutocomplete } from "../plugins/init_autocomplete";
import { init_plant_dragging } from "../plugins/init_plant_dragging";
import "../plugins/flatpickr"
import "../plugins/modal_confirm"
// set autocomplete on garden address field if it exists
initAutocomplete('garden_address');

// setup initial plant plot with dragging
init_plant_dragging();
