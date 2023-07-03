FROM jekyll/jekyll

COPY Gemfile Gemfile.lock ./
RUN bundle install
