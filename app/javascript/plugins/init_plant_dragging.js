import interact from 'interactjs';

// for axaj requests
var xhttp = new XMLHttpRequest();
var csrfToken = document.querySelector('meta[name="csrf-token"]').content;

// setup global grid setup vars
var plants_container = document.getElementById('plot-container');
if (plants_container) {
  var wheelbarrow = document.getElementById('wheelbarrow');
  // determine grid spacing based of viewport size and plot size
  const intViewportHeight = window.innerHeight;
  // var intViewportWidth = window.innerWidth * 0.9;
  const page_container = document.querySelector('.container');
  const intViewportWidth = page_container.clientWidth * 0.95;
  const length = parseInt(plants_container.dataset.length);
  const width = parseInt(plants_container.dataset.width);
  // set the grid scale (i.e. each grid cell is how many mm?
  var grid_cell_mm = parseInt(plants_container.dataset.grid);;
  // work out how many rows and columns we want in the grid
  var grid_rows =  length / grid_cell_mm;
  var grid_cols = width / grid_cell_mm;
  // work out scaling factors
  var mm_per_pixel = width / intViewportWidth;
  var grid_size = intViewportWidth / grid_cols;
  // console.log(grid_rows, grid_cols, mm_per_pixel, grid_size);
  // set container style and dimensions
  plants_container.style.height = `${length / mm_per_pixel}px`;
  plants_container.style.width = `${width / mm_per_pixel}px`;
}


const add_plant_to_plot=(plant) => {
  // generate a plant div with a nested thumbnail image
  const plant_div = document.createElement('div');
  const thumbnail = document.createElement('div');
  const plant_border = document.createElement('div');
  const delete_link = document.createElement('a');

  // set plant div id and css properties
  plant_div.classList.add('plot-plant');
  plant_div.setAttribute('data-id', plant.id);
  plant_div.style.width = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.height = `${plant.radius_mm * 2 / mm_per_pixel}px`;

  // style plant border
  plant_border.classList.add('plot-plant-border');

  // Add delete link
  //  'data-confirm="Are you sure you want to remove this plant?" rel="nofollow" data-method="delete" href="/plants/1"'
  delete_link.classList.add('plot-plant-delete');
  delete_link.setAttribute('data-confirm', "Are you sure you want to remove this plant?");
  delete_link.setAttribute('rel', "nofollow");
  delete_link.setAttribute('data-method', "delete");
  delete_link.setAttribute('href', `/plants/${plant.id}`);
  delete_link.innerHTML= `<i class="fas fa-trash"></i>`;

  // style thumbnail image
  thumbnail.classList.add('plot-plant-thumbnail');
  // thumbnail.style.backgroundImage = `url("https://res.cloudinary.com/dm6mj1qp1/image/upload/v1583325509/${plant.photo_url}")`;
  thumbnail.style.backgroundImage = `url("${plant.icon}")`;

  // insert the thumbnail/border into the plant div
  plant_border.appendChild(thumbnail);
  plant_div.appendChild(plant_border);
  plant_div.appendChild(delete_link);

  // insert the plant div into the plot container
  plants_container.appendChild(plant_div);

  return plant_div;
}

const init_ineractjs=(plant) => {
  console.log(`Adding new plant id:${plant.id} type:${plant.plant_type} x:${plant.x} y:${plant.y}`);
  // create plant element
  const element = add_plant_to_plot(plant);

  // set wheelbarrow dimensions based on any unplaced plants (negative coordinates)
  if ((plant.y < 0 || plant.y == null) || (plant.x < 0 || plant.x == null)) {
    wheelbarrow.innerHTML = "Drag the plant onto the plot...";
    // plant dimensions
    let plant_size = 2*plant.radius_mm/mm_per_pixel;
    // plant is in the wheelbarrow, resize it if necessary to fit the plant
    let current_height = wheelbarrow.clientHeight;
    let current_width = wheelbarrow.clientWidth;
    if (current_height < plant_size) {
      wheelbarrow.style.height = `${plant_size}px`;
      current_height = plant_size;
    }
    if (current_width < plant_size) {
      wheelbarrow.style.width = `${plant_size}px`;
      current_width = plant_size;
    }
    // position plant in center of wheelbarrow area
    plant.y = Math.round(-current_height/grid_size);
    // console.log(grid_size, grid_cols, plant_size/grid_size, Math.round(current_width/2/grid_size));
    plant.x = Math.round(grid_cols - (plant_size/grid_size));
  }

  // store inital positions
  plant.initial_x = plant.x
  plant.initial_y = plant.y

  let x = plant.x * grid_size;
  let y = plant.y * grid_size;
  element.style.transform = 'translate(' + x + 'px, ' + y + 'px)';

  interact(element)
    .draggable({
      modifiers: [
        interact.modifiers.snap({
          targets: [
            interact.createSnapGrid({ x: grid_size, y: grid_size })
          ],
          range: Infinity,
          relativePoints: [ { x: 0, y: 0 } ]
        }),
        interact.modifiers.restrict({
          restriction: element.parentNode,
          elementRect: { top: 0, left: 0, bottom: 1, right: 1 },
          endOnly: true
        })
      ],
      inertia: true,
      listeners: {
        end: (event) => {
          //console.log(event.currentTarget.dataset.id, plant.x, plant.y, x, y);
          // send x and y with fetch
          const url = `/plants/${element.dataset.id}`
          fetch(url, { method: "PATCH",
                       headers: { 'Content-Type': 'application/json',
                                  'x-csrf-token': csrfToken },
                       body: JSON.stringify(plant),
                      })
            .then(res => res.json())
            .then((data) => {
              if (data.accepted) {
                // if response ok, keep updated plant x/y
                console.log(`plant ${plant.id} moved to x:${plant.x} y:${plant.y}`);
                // if the plant moved was a new one, add a copy to the wheelbarrow area
                if (plant.initial_y < 0) {
                  console.log("Adding new plant...");
                  // create a new plant the same as this one
                  // also update the list of plants in the garden
                  let copy_plant = plant;
                  copy_plant.x = plant.initial_x;
                  copy_plant.y = plant.initial_y;
                  xhttp.open("POST", "/plants", true);
                  xhttp.setRequestHeader("Content-type", "application/json");
                  xhttp.setRequestHeader("x-csrf-token", csrfToken);
                  xhttp.send(JSON.stringify(copy_plant));

                }
              } else {
                // move it back to where it was or the initial position
                (data.x == null) ? plant.x = plant.initial_x : plant.x = data.x;
                (data.y == null) ? plant.y = plant.initial_y : plant.y = data.y;
                x = plant.x * grid_size;
                y = plant.y * grid_size;
                event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
                console.log(data.errors.base[0]);
                // modal
                const modal_btn = document.getElementById('error-modal-button');
                const modal_body = document.getElementById('error-modal-body');
                modal_body.innerHTML = data.errors.base[0];
                modal_btn.click();
              }
            })
        }
      }
    })
    .on('dragmove', function (event) {
      // update plant position (in number of grid cells, not pixels)
      plant.x += Math.round((event.dx / grid_size))
      plant.y += Math.round((event.dy / grid_size))
      // make sure current position matches what is in plant
      x = plant.x * grid_size;
      y = plant.y * grid_size;
      event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
    })
}



const init_plant_dragging=() => {
  // check if we have a plant plot on the page
  const plants_container = document.getElementById('plot-container');
  if (plants_container) {
    // first destroy any children already in the plot
    plants_container.innerHTML = "";
    // now go through each plant and add it to the plot
    const plants = JSON.parse(plants_container.dataset.plants);
    plants.forEach((plant) => {
      // attach the interact plugin to the plant
      init_ineractjs(plant);
    });
  }
}

export { init_plant_dragging, init_ineractjs };
