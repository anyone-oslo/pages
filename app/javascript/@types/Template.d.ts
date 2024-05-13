declare namespace Template {
  interface Block {
    name: string;
    title: string;
    description?: string;
    optional: boolean;
    enforced: boolean;
    size: string;
    class?: string;
    localized?: boolean;
    placeholder?: string;
    options?: [string, string][];
    type?: string;
  }

  interface Config {
    name: string;
    template_name: string;
    blocks: Block[];
    metadata_blocks: Block[];
    images: boolean;
    dates: boolean;
    tags: boolean;
    files: boolean;
  }
}
