.PHONY: all install clean pub_get lint lint_fix test coverage coverage_open

all: install

install: clean pub_get

clean:
	@echo "🧹 cleaning..."
	fvm flutter clean

pub_get:
	@echo "📦 pub get..."
	fvm flutter pub get

lint:
	@echo "⚡ lint..."
	fvm flutter analyze --fatal-infos

lint_fix:
	@echo "🛠️ auto-fix (dart fix --apply)..."
	fvm dart fix --apply

test:
	@echo "🧪 test..."
	fvm flutter test

coverage:
	@echo "🧮 coverage..."
	fvm flutter test --coverage
	@if ! command -v lcov >/dev/null 2>&1; then \
		echo "lcov not found. Can't enforce coverage threshold." ; \
		exit 1 ; \
	fi
	lcov --ignore-errors unused --remove coverage/lcov.info \
		'lib/main.dart' \
		'lib/**/generated/**' \
		-o coverage/lcov.info
	@echo "📊 Evaluating coverage threshold (>= 85%)..."
	@pct=$$(lcov --summary coverage/lcov.info 2>/dev/null | perl -ne 'if(/^[[:space:]]*lines.*:[[:space:]]*([0-9.]+)%/){print $$1; exit}'); \
	if [ -z "$$pct" ]; then \
		echo "Could not parse coverage percentage from lcov summary." ; \
		exit 1 ; \
	fi; \
	if awk -v pct="$$pct" 'BEGIN{exit (pct+0>=85)?0:1}'; then \
		echo "Coverage: $$pct% (OK)"; \
	else \
		echo "Coverage: $$pct% (< 85%). Failing."; \
		exit 1 ; \
	fi

coverage_open: coverage
	@echo "🌐 Generating HTML..."
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html
