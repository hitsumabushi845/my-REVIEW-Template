FROM vvakame/review:5.9

WORKDIR /book

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev \
    python3 python3-pip inotify-tools \
    && pip install --break-system-packages pygments \
    && rm -rf /var/lib/apt/lists/*

# Install custom Pygments lexers
# COPY pygments-snowflake-lexers /book/pygments-snowflake-lexers
# RUN pip install --break-system-packages /book/pygments-snowflake-lexers /book/pygments-wit-lexer

# Install Ruby dependencies
COPY Gemfile /book/
RUN bundle install

# Install Node.js dependencies
COPY package.json package-lock.json* /book/
RUN npm install --unsafe-perm

# Copy the rest of the project
COPY . /book/
