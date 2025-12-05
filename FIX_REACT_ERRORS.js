// Fix React DOM compatibility issues
const fs = require('fs');
const path = require('path');

console.log('🔧 Fixing React DOM compatibility issues...');

// Fix Blueprint.js React 18 compatibility
const blueprintPackages = [
  'node_modules/@blueprintjs/core/lib/esm/components/context-menu/contextMenuSingleton.js',
  'node_modules/@blueprintjs/core/lib/esm/components/toast/overlayToaster.js',
  'node_modules/@blueprintjs/core/lib/esm/legacy/contextMenuLegacy.js',
  'node_modules/@blueprintjs/core/lib/esm/legacy/contextMenuTargetLegacy.js'
];

blueprintPackages.forEach(filePath => {
  const fullPath = path.join(__dirname, filePath);
  if (fs.existsSync(fullPath)) {
    try {
      let content = fs.readFileSync(fullPath, 'utf8');
      
      // Fix React DOM import issues
      content = content.replace(/import \* as ReactDOM from 'react-dom'/g, "import * as ReactDOM from 'react-dom/client'");
      content = content.replace(/ReactDOM\.render/g, 'ReactDOM.createRoot(container).render');
      content = content.replace(/ReactDOM\.unmountComponentAtNode/g, 'ReactDOM.createRoot(container).unmount');
      content = content.replace(/ReactDOM\.findDOMNode/g, '// ReactDOM.findDOMNode (deprecated)');
      
      fs.writeFileSync(fullPath, content);
      console.log(`✅ Fixed: ${filePath}`);
    } catch (error) {
      console.log(`⚠️ Could not fix: ${filePath} - ${error.message}`);
    }
  } else {
    console.log(`⚠️ File not found: ${filePath}`);
  }
});

console.log('🎉 React DOM compatibility fixes applied!');