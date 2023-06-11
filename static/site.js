// Global state of mouse having ever moved
let moved = false;

const ID = "pointer";

const CIRCLE = 10;

const toPx = (n) => `${n}px`;

const getPointer = () => document.getElementById(ID);

const resizePointer = (pointer, w, h) => {
  pointer.style.width = toPx(w);
  pointer.style.height = toPx(h);
};

const movePointer = (pointer, x, y) => {
  // Use an offset to have it positioned centered on the pointer tip
  const offset_x = x - 8;
  const offset_y = y - 9;

  pointer.style.left = toPx(offset_x);
  pointer.style.top = toPx(offset_y);
};

window.onload = (event) => {
  // Dynamically create the pointer
  let pointer = document.createElement("div");
  pointer.id = ID;
  document.body.appendChild(pointer);

  // Interact with the anchors
  const anchors = document.getElementsByTagName("a");

  for (let anchor of anchors) {
    // Make smaller
    anchor.onmouseenter = (event) => {
      let pointer = getPointer();

      resizePointer(pointer, 5, 5);
      pointer.style.backgroundColor = "#EF8A7E";

      // Let it transition back
      setTimeout(() => {
        pointer.style.backgroundColor = colourSchemeToColour();
      }, 5000);
    };

    // Make bigger
    anchor.onmouseleave = (event) => {
      let pointer = getPointer();

      resizePointer(pointer, 10, 10);
      pointer.style.backgroundColor = colourSchemeToColour();
    };
  }
};

const colourSchemeToColour = () => {
  const darkModeMediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

  if (darkModeMediaQuery.matches) {
    return "#fff";
  } else {
    return "#000";
  }
};

document.onmousemove = (event) => {
  let pointer = getPointer();

  if (!moved) {
    pointer.style.display = "block";
    moved = true;
  }

  // Since there's redrawing, it lags already
  movePointer(pointer, event.pageX, event.pageY);
};
