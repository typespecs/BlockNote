import "@typespec/json-schema";

using TypeSpec.JsonSchema;

@jsonSchema
namespace BlockNote;

/**
 * BlockNote Document Structure
 *
 * A BlockNote document is composed of a hierarchical structure of blocks.
 * Each block can contain inline content and nested child blocks.
 */
/**
 * A unique identifier for a block
 */
scalar BlockId extends string;

/**
 * Default properties available on all block types
 */
model DefaultProps {
  /**
   * The background color of the block, which also applies to nested blocks.
   * @default "default"
   */
  backgroundColor?: string = "default";

  /**
   * The text color of the block, which also applies to nested blocks.
   * @default "default"
   */
  textColor?: string = "default";

  /**
   * The text alignment of the block.
   * @default "left"
   */
  textAlignment?: "left" | "center" | "right" | "justify" = "left";
}

/**
 * Text styles that can be applied to styled text
 */
model Styles {
  /**
   * Whether the text is bold.
   * @default false
   */
  bold?: boolean = false;

  /**
   * Whether the text is italic.
   * @default false
   */
  italic?: boolean = false;

  /**
   * Whether the text is underlined.
   * @default false
   */
  underline?: boolean = false;

  /**
   * Whether the text is struck through.
   * @default false
   */
  strike?: boolean = false;

  /**
   * Whether the text is formatted as inline code.
   * @default false
   */
  code?: boolean = false;

  /**
   * The text color.
   * @default "default"
   */
  textColor?: string = "default";

  /**
   * The background color of the text.
   * @default "default"
   */
  backgroundColor?: string = "default";
}

/**
 * Discriminator enum for all inline content types
 */
enum InlineContentType {
  text,
  link,
}

/**
 * Styled text with formatting
 */
@discriminator("type")
model StyledText {
  type: InlineContentType.text;

  /**
   * The text content
   */
  text: string;

  /**
   * The styles applied to the text
   */
  styles?: Styles;
}

/**
 * A hyperlink containing styled text
 */
@discriminator("type")
model Link {
  type: InlineContentType.link;

  /**
   * The styled text content within the link
   */
  content: StyledText[];

  /**
   * The URL the link points to
   */
  href: string;
}

/**
 * All inline content types
 */
alias InlineContent = StyledText | Link;

/**
 * A table cell within a table
 */
model TableCell {
  type: "tableCell";

  /**
   * Cell properties including span and colors
   */
  props: {
    /**
     * Number of columns this cell spans
     */
    colspan?: numeric;

    /**
     * Number of rows this cell spans
     */
    rowspan?: numeric;
  };

  /**
   * The inline content within the cell
   */
  content: InlineContent[];
}

/**
 * Table content structure
 */
model TableContent {
  type: "tableContent";

  /**
   * Width of each column in pixels
   */
  columnWidths?: numeric[];

  /**
   * Number of header rows
   */
  headerRows?: numeric;

  /**
   * The rows of the table
   */
  rows: {
    /**
     * Cells within this row
     */
    cells: TableCell[];
  }[];
}

/**
 * Discriminator enum for all block types
 */
enum BlockType {
  paragraph,
  heading,
  quote,
  bulletListItem,
  numberedListItem,
  checkListItem,
  toggleListItem,
  codeBlock,
  divider,
  file,
  image,
  video,
  audio,
  table,
  column,
  columnList,
}

/**
 * Paragraph block
 */
@discriminator("type")
model ParagraphBlock {
  id: BlockId;
  type: BlockType.paragraph;
  props: DefaultProps;
  content: InlineContent[];
  children: Block[];
}

/**
 * Heading block with levels 1-6
 */
@discriminator("type")
model HeadingBlock {
  id: BlockId;
  type: BlockType.heading;
  props: {
    /**
     * The heading level (1 = title, 2 = heading, 3 = subheading)
     * @default 1
     */
    level?: 1 | 2 | 3 | 4 | 5 | 6 = 1;

    /**
     * Whether the heading is toggleable (collapsible)
     * @default false
     */
    isToggleable?: boolean = false;

    ...DefaultProps;
  };
  content: InlineContent[];
  children: Block[];
}

/**
 * Quote block for blockquotes
 */
@discriminator("type")
model QuoteBlock {
  id: BlockId;
  type: BlockType.quote;
  props: {
    /** @default "default" */
    backgroundColor?: string = "default";

    /** @default "default" */
    textColor?: string = "default";
  };
  content: InlineContent[];
  children: Block[];
}

/**
 * Bullet list item block
 */
@discriminator("type")
model BulletListItemBlock {
  id: BlockId;
  type: BlockType.bulletListItem;
  props: DefaultProps;
  content: InlineContent[];
  children: Block[];
}

/**
 * Numbered list item block
 */
@discriminator("type")
model NumberedListItemBlock {
  id: BlockId;
  type: BlockType.numberedListItem;
  props: {
    /**
     * The number of this list item
     */
    start?: numeric;

    ...DefaultProps;
  };
  content: InlineContent[];
  children: Block[];
}

/**
 * Check list item block (todo item)
 */
@discriminator("type")
model CheckListItemBlock {
  id: BlockId;
  type: BlockType.checkListItem;
  props: {
    /**
     * Whether the list item is checked
     * @default false
     */
    checked?: boolean = false;

    ...DefaultProps;
  };
  content: InlineContent[];
  children: Block[];
}

/**
 * Toggle list item block (collapsible)
 */
@discriminator("type")
model ToggleListItemBlock {
  id: BlockId;
  type: BlockType.toggleListItem;
  props: DefaultProps;
  content: InlineContent[];
  children: Block[];
}

/**
 * Code block with optional syntax highlighting
 */
@discriminator("type")
model CodeBlock {
  id: BlockId;
  type: BlockType.codeBlock;
  props: {
    /**
     * The syntax highlighting language
     * @default "text"
     */
    language?: string = "text";
  };
  content: InlineContent[];
  children: Block[];
}

/**
 * Divider (horizontal rule) block
 */
@discriminator("type")
model DividerBlock {
  id: BlockId;
  type: BlockType.divider;
  props: {};
  content?: void;
  children: Block[];
}

/**
 * File embed block
 */
@discriminator("type")
model FileBlock {
  id: BlockId;
  type: BlockType.file;
  props: {
    /** @default "" */
    name?: string = "";

    /** @default "" */
    url?: string = "";

    /** @default "" */
    caption?: string = "";

    /** @default "default" */
    backgroundColor?: string = "default";
  };
  content?: void;
  children: Block[];
}

/**
 * Image block
 */
@discriminator("type")
model ImageBlock {
  id: BlockId;
  type: BlockType.image;
  props: {
    /** @default "default" */
    backgroundColor?: string = "default";

    /** @default "left" */
    textAlignment?: "left" | "center" | "right" | "justify" = "left";

    /** @default "" */
    name?: string = "";

    /** @default "" */
    url?: string = "";

    /** @default "" */
    caption?: string = "";

    /** @default true */
    showPreview?: boolean = true;

    /**
     * The image preview width in pixels. No fixed width when not set.
     */
    previewWidth?: numeric;
  };
  content?: void;
  children: Block[];
}

/**
 * Video block
 */
@discriminator("type")
model VideoBlock {
  id: BlockId;
  type: BlockType.video;
  props: {
    /** @default "" */
    name?: string = "";

    /** @default "" */
    url?: string = "";

    /** @default "" */
    caption?: string = "";

    /** @default true */
    showPreview?: boolean = true;

    previewWidth?: numeric;

    /** @default "default" */
    backgroundColor?: string = "default";

    /** @default "left" */
    textAlignment?: "left" | "center" | "right" | "justify" = "left";
  };
  content?: void;
  children: Block[];
}

/**
 * Audio block
 */
@discriminator("type")
model AudioBlock {
  id: BlockId;
  type: BlockType.audio;
  props: {
    /** @default "" */
    name?: string = "";

    /** @default "" */
    url?: string = "";

    /** @default "" */
    caption?: string = "";

    /** @default true */
    showPreview?: boolean = true;

    /** @default "default" */
    backgroundColor?: string = "default";
  };
  content?: void;
  children: Block[];
}

/**
 * Table block
 */
@discriminator("type")
model TableBlock {
  id: BlockId;
  type: BlockType.table;
  props: {
    /** @default "default" */
    textColor?: string = "default";
  };
  content: TableContent;
  children: Block[];
}

/**
 * Column block for multi-column layout
 */
@discriminator("type")
model ColumnBlock {
  id: BlockId;
  type: BlockType.column;
  props: {
    /**
     * Width of the column
     */
    width: numeric;
  };
  content?: void;
  children: Block[];
}

/**
 * Column list block for multi-column layout
 */
@discriminator("type")
model ColumnListBlock {
  id: BlockId;
  type: BlockType.columnList;
  props: {};
  content?: void;

  /**
   * Nested child blocks (must be ColumnBlock, minimum 2)
   */
  children: ColumnBlock[];
}

/**
 * All block types
 */
union Block {
  ParagraphBlock,
  HeadingBlock,
  QuoteBlock,
  BulletListItemBlock,
  NumberedListItemBlock,
  CheckListItemBlock,
  ToggleListItemBlock,
  CodeBlock,
  DividerBlock,
  FileBlock,
  ImageBlock,
  VideoBlock,
  AudioBlock,
  TableBlock,
  ColumnBlock,
  ColumnListBlock,
}
