import os, sys, numpy as np

matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Ellipse

# NOTE: Ellipse must be imported at module level, not inside functions
# or subsequent functions will get NameError

NATURE_COLORS = {
    'blue': '#0F4D92',
    'green': '#8BCF8B',
    'red': '#B64342',
    'gray': '#999999',
    'teal': '#42949E',
}

def save_figure(fig, name):
    """Save SVG+PNG+PDF.
    
    BUG FIX (2026-07-11): matplotlib 3.11+ does NOT accept svg_fonttype
    parameter in savefig(). Remove svg_fonttype='none' from SVG save.
    Only use svg.fonttype in rcParams, not savefig kwargs.
    """
    os.makedirs(os.path.dirname(os.path.abspath(name)), exist_ok=True)
    
    # SVG — NO svg_fonttype for matplotlib 3.11+
    svg_path = name + '.svg'
    fig.savefig(svg_path, bbox_inches='tight', pad_inches=0.1,
               facecolor='white', edgecolor='none')
    
    # PNG — 300 DPI
    fig.savefig(name, dpi=300, bbox_inches='tight', pad_inches=0.1)
    
    # PDF
    pdf_path = name + '.pdf'
    fig.savefig(pdf_path, bbox_inches='tight', pad_inches=0.1)

def setup_plot(figsize=(4.5, 3.5), fontsize=8):
    fig, ax = plt.subplots(figsize=figsize)
    plt.rcParams.update({
        'font.size': fontsize,
        'font.family': 'sans-serif',
        'svg.fonttype': 'none',
        'axes.spines.top': False,
        'axes.spines.right': False,
        'axes.linewidth': 0.6,
        'savefig.dpi': 300,
        'savefig.bbox': 'tight',
        'savefig.pad_inches': 0.1,
    })
    return fig, ax