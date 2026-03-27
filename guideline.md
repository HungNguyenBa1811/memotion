Role: Act as an Expert UI/UX Designer and Frontend Architect.

Task: Design a highly responsive 
+ <Hieuvu>
+ <Hainam>
+ <Thoa>
+ <Hung>
that scales perfectly from a standard mobile phone to a large tablet.

1. Target Devices & Breakpoints:

Mobile Breakpoint (Base): Optimized for ~392dpi screens (e.g., standard Xiaomi phones). Vertical orientation.

Tablet Breakpoint (Expanded): Optimized for ~754dpi large screens (e.g., Galaxy Tab A9). Horizontal/Landscape orientation.

2. Layout & Structural Rules (Crucial):

Think in components and Flexbox/Grid logic. Do not just stretch the mobile UI.

Mobile: Use a single-column layout (Column), full-width cards, and bottom navigation. Focus on vertical scrolling.

Tablet: Restructure the layout. Switch to a left-side Navigation Rail or Side Drawer. Convert single columns into a split-pane (Master-Detail) or a multi-column masonry/grid layout (Row wrapping Expanded or Flexible widgets). Use the extra width to display secondary information that was hidden on mobile.

3. The "Small Icon, Big Box" Fix (Strict Constraints):

Dynamic Iconography: Icons MUST scale proportionally with their containers. Do NOT use fixed pixel sizes for icons across breakpoints.

Sizing Matrix: >     * On Mobile (392dpi): Base icon visual size is 24x24dp.

On Tablet (754dpi): As the container/box expands, the icon visual size MUST scale up to 36x36dp or 40x40dp to maintain visual harmony.

Vector & Touch: Assume all icons are SVGs. Always maintain a minimum interactive touch target of 48x48dp regardless of the visual icon size.

4. Typography:

Use a fluid typography scale. Body text should be legible (e.g., 14sp-16sp on mobile, scaling to 16sp-18sp on tablet). Headings should scale up noticeably on the tablet breakpoint.

5. Expected Output:
Please provide:

A clear visual description of the mobile vs. tablet layout.

The structural breakdown (explaining the Flexbox/Grid behavior: what wraps, what expands, what stays fixed).

Explicit size values (in dp/sp) for paddings, icons, and fonts at both breakpoints to prove they scale correctly.